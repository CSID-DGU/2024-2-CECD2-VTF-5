import 'dart:io';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RecordingService {
  final record = AudioRecorder();
  String? _recordingPath;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  // 녹음 시작
  Future<void> startRecording() async{
    if (await record.hasPermission()) {
      final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(appDocumentsDir.path, "recording.aac");
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
      await sendFileToServer(_recordingPath!);
    }
  }

  Future<void> sendFileToServer(String filePath) async {
    File audioFile = File(filePath);
    String url = "http://127.0.0.1:8000/generate_question";

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('recordFile', audioFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('파일 업로드 성공');
      } else {
        print('파일 업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('에러: $e');
    }
    
  }
}

