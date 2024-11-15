import 'package:flutter/material.dart';
import '../model/login.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool _keepLoggedIn = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 요소를 양 끝과 가운데로 배치
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/leftleaf.png',
                          width: 80,
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
                        angle: 3.14159, // 180도
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/rightleaf.png',
                            width: 80,
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
                        // 아이디 필드
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
                          validator: (value) =>
                          value == null || value.isEmpty ? '아이디를 입력하세요' : null,
                        ),
                        const SizedBox(height: 24),
                        // 비밀번호 필드
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
                        // 로그인 유지 체크박스
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
                // 로그인 버튼
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      print('로그인 성공');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('로그인'),
                ),
                const SizedBox(height: 24),
                // 카카오 로그인 버튼
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
                // 회원가입 및 비밀번호 찾기
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        print('회원가입 클릭');
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

