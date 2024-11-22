import 'dart:io';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/question.dart';
import '../provider/question_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecordingService {
  final record = AudioRecorder();
  String? _recordingPath;
  bool _isRecording = false;
  List<String> responses = []; // 서버로 전송할 응답 리스트

  bool get isRecording => _isRecording;

  // 녹음 시작
  Future<void> startRecording() async {
    if (await record.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "recordFile.aac");
      await record.start(const RecordConfig(), path: filePath);
      _isRecording = true;
      _recordingPath = filePath;
    }
  }

  // 녹음 중지
  Future<void> stopRecording() async {
    _recordingPath = await record.stop();
    _isRecording = false;
    if (_recordingPath != null) {
      String? responseBody = await sendFileToServer(_recordingPath!);
      if (responseBody != null) {
        responses.add(responseBody);
        print('서버 응답: $responseBody');
      } else {
        print('서버 응답 없음 또는 실패');
      }
    }
  }

  // 파일 서버 전송
  Future<String?> sendFileToServer(String filePath) async {
    File audioFile = File(filePath);
    String url = "${AppConfig.apiBaseUrl}/stt";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('recordFile', audioFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return responseBody;
      } else {
        print('파일 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러: $e');
    }
    return null;
  }

  // responses 리스트 서버 전송
  Future<List<Question>?> sendResponsesToServer() async {
    String url = "${AppConfig.apiBaseUrl}/generate_question";

    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    Future<String?> getAccessToken() async {
      return await _secureStorage.read(key: 'accessToken');
    }

    String? token = await getAccessToken();
    if (token == null) {
      print("Access Token이 없습니다.");
      return null;
    }

    String bearerToken = "Bearer $token";

    if (responses.isEmpty) {
      print("responses 리스트가 비어 있습니다.");
      return null;
    }

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $bearerToken",
    };

    var body = json.encode({"stt_input": responses.join("\n")});

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // 서버로부터 JSON 응답 파싱
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> responseBody = json.decode(decodedBody);
        List<Question> questions = (responseBody['questions'] as List)
            .map((item) => Question.fromJson(item))
            .toList();
        return questions;
      } else {
        print('responses 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러: $e');
    }
    return null;
  }
  // responses 리스트 초기화 메서드
  void clearResponses() {
    this.responses = [];
    print('responses 리스트가 초기화되었습니다.');
  }

}
