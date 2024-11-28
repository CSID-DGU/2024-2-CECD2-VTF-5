import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class numOfCharacters {
  Future<int?> fetchNumber() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/complete');
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

    final response = await http.post(
      url,
      headers: {
        'Authorization': '$bearerToken', // Bearer 토큰 추가
        'Content-Type': 'application/json', // 필요에 따라 추가
      },
    );

    if (response.statusCode == 200) {
      final decodedBody=utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      return data['content_length'];
    } else {
      print('Error: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load autobiography content');
    }
  }
}
