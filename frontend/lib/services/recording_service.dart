import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/question.dart';
import '../provider/responsesProvider.dart';

class RecordingService {
  final record = AudioRecorder();
  String? _recordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  final Ref ref; // Ref를 추가합니다.

  RecordingService(this.ref);

  void clearResponses() {
    ref.read(responsesProvider.notifier).clearResponses();
  }

  void addResponse(String response) {
    ref.read(responsesProvider.notifier).addResponse(response);
  }

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
      Map<String, dynamic>? responseBody = await sendFileToServer(_recordingPath!);
      if (responseBody != null && responseBody.containsKey('text')) {
        ref.read(responsesProvider.notifier).addResponse(responseBody['text']);
        print('서버 응답: ${responseBody['text']}');
      } else {
        print('서버 응답 없음 또는 실패');
      }
    }
  }

  // 파일 서버 전송
  Future<Map<String, dynamic>?> sendFileToServer(String filePath) async {
    File audioFile = File(filePath);
    String url = "${AppConfig.apiBaseUrl}/stt";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('recordFile', audioFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        print('파일 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러: $e');
    }
    return null;
  }

  // responses 리스트 서버 전송
  Future<QuestionModel?> sendResponsesToServer() async {
    String url = "${AppConfig.apiBaseUrl}/generate_question";

    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    Future<String?> getAccessToken() async {
      String? tokenData= await _secureStorage.read(key: 'loginData');
      if (tokenData != null) {
        try {
          // JSON 문자열을 Map으로 변환
          final Map<String, dynamic> tokenMap = json.decode(tokenData);

          // accessToken 값 추출
          return tokenMap['accessToken'] as String?;
        } catch (e) {
          // JSON 파싱 에러 처리
          print('Error decoding JSON: $e');
          return null;
        }
      }
      return null;
    }

    String? token = await getAccessToken();
    print("$token");
    if (token == null) {
      print("Access Token이 없습니다.");
      return null;
    }

    String bearerToken = "Bearer $token";

    final responses = ref.read(responsesProvider);
    if (responses.isEmpty) {
      print("responses 리스트가 비어 있습니다.");
      return null;
    }

    String sttInput = responses.join(" ");

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "$bearerToken",
    };

    var body = json.encode({"stt_input": sttInput});
    print("Headers: $headers");
    print("Body: $body");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}"); // 텍스트 응답 그대로 출력

      if (response.statusCode == 200) {
        // 성공 시 단순 텍스트 응답 처리
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> responseBody = json.decode(decodedBody);
        print("Success Response: $responseBody");
        print("Questions: ${responseBody['questions']}");
        QuestionModel questionModel =
        QuestionModel.fromList(responseBody['questions']);
        return questionModel;
        // 필요하다면 텍스트를 화면에 표시하거나 로직에 활용
      } else {
        // 오류 시 텍스트 응답 처리
        String errorBody = utf8.decode(response.bodyBytes);
        print("Error Response Body: $errorBody");
        return null;

      }
    } catch (e) {
      // 네트워크 요청 또는 기타 예외 처리
      print("Request failed with exception: $e");
      return null;

    }

    return null;
  }

  Future<QuestionModel?> sendResponsesToServerDD() async {
    String url = "${AppConfig.apiBaseUrl}/generate_new_topic_question";

    final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

    Future<String?> getAccessToken() async {
      String? tokenData= await _secureStorage.read(key: 'loginData');
      if (tokenData != null) {
        try {
          // JSON 문자열을 Map으로 변환
          final Map<String, dynamic> tokenMap = json.decode(tokenData);

          // accessToken 값 추출
          return tokenMap['accessToken'] as String?;
        } catch (e) {
          // JSON 파싱 에러 처리
          print('Error decoding JSON: $e');
          return null;
        }
      }
      return null;
    }

    String? token = await getAccessToken();
    print("$token");
    if (token == null) {
      print("Access Token이 없습니다.");
      return null;
    }

    String bearerToken = "Bearer $token";

    final responses = ref.read(responsesProvider);
    if (responses.isEmpty) {
      print("responses 리스트가 비어 있습니다.");
      return null;
    }

    String sttInput = responses.join(" ");

    var headers = {
      "Content-Type": "application/json",
      "Authorization": "$bearerToken",
    };

    var body = json.encode({"stt_input": sttInput});
    print("Headers: $headers");
    print("Body: $body");

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Headers: ${response.headers}");
      print("Response Body: ${response.body}"); // 텍스트 응답 그대로 출력

      if (response.statusCode == 200) {
        // 성공 시 단순 텍스트 응답 처리
        String decodedBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> responseBody = json.decode(decodedBody);
        print("Success Response: $responseBody");
        print("Questions: ${responseBody['new_topic_questions']}");
        QuestionModel questionModel =
        QuestionModel.fromList(responseBody['new_topic_questions']);
        return questionModel;
        // 필요하다면 텍스트를 화면에 표시하거나 로직에 활용
      } else {
        // 오류 시 텍스트 응답 처리
        String errorBody = utf8.decode(response.bodyBytes);
        print("Error Response Body: $errorBody");
        return null;

      }
    } catch (e) {
      // 네트워크 요청 또는 기타 예외 처리
      print("Request failed with exception: $e");
      return null;

    }

    return null;
  }
}
