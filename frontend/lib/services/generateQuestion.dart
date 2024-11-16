import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/recording_service.dart';

class genQuestionService {
  List<String> useResponses() {
    // Access singleton RecordingService
    RecordingService recordingService = RecordingService();
    // Access and modify responses
    return recordingService.responses;
  }


    Future<void> sendResponsesToServer() async {
    String url = "http://10.0.2.2:8000/send-responses";
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXNkdDEyMzEiLCJleHAiOjE3MzE2Njg4ODd9.qygUGs3ijtTeSbWii1e068ZQQpXl_CAca5C7fau1tgo";

    for (String responseText in useResponses()) {
      Map<String, dynamic> body = {'response': responseText};

      try {
        var response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          print('서버 응답 성공: ${response.body}');
        } else {
          print('서버 전송 실패: ${response.statusCode}');
        }
      } catch (e) {
        print('에러 발생: $e');
      }
    }
  }
}

