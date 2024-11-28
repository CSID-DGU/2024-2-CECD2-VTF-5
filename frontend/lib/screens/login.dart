import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/loginModel.dart';
import 'package:get/get.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _passwordVisible = false;
  bool _keepLoggedIn = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveTokenToStorage(String accessToken) async {
    final loginData = loginModel(accessToken: accessToken);
    await _secureStorage.write(key: 'loginData', value: jsonEncode(loginData.toJson()));
  }

  Future<void> _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final url = Uri.parse('${AppConfig.apiBaseUrl}/login');
    print('${AppConfig.apiBaseUrl}/login');// 서버 URL
    final body = jsonEncode({'login_id': id, 'password': password});
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['access_token'] != null) {
          final String accessToken = responseData['access_token'];

          // Secure Storage에 토큰 저장
          await _saveTokenToStorage(accessToken);

          // 다음 화면으로 이동
          Navigator.pushReplacementNamed(context, '/homePage'); // Replace '/home' with your target route name
        } else {
          _showError('토큰없음');
        }
      } else {
        _showError('error ${response.statusCode}');
      }
    } catch (e) {
      _showError('네트워크 오류가 발생했습니다.');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F9EA),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 이미지 배너
                Container(
                  width: double.infinity,
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/leftleaf.png',
                          width: 66,
                          height: 200,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/writer.png',
                          width: 200,
                          height: 200,
                        ),
                      ),
                      Transform.rotate(
                        angle: 3.14159,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/rightleaf.png',
                            width: 70,
                            height: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 로그인 제목
                Text(
                  '로그인을 해주세요',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // 로그인 입력 필드
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('아이디'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _idController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? '아이디를 입력하세요'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text('비밀번호'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? '비밀번호를 입력하세요'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _keepLoggedIn,
                              onChanged: (value) {
                                setState(() {
                                  _keepLoggedIn = value ?? false;
                                });
                              },
                            ),
                            const Text('로그인 유지'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('로그인'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    print('카카오로 로그인');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: const Icon(
                    Icons.chat_bubble,
                    color: Colors.black,
                  ),
                  label: const Text(
                    '카카오로 로그인',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.toNamed('/signup');
                      },
                      child: const Text('회원가입'),
                    ),
                    const Text('|'),
                    TextButton(
                      onPressed: () {
                        print('비밀번호 찾기 클릭');
                      },
                      child: const Text('비밀번호를 잊으셨나요?'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
