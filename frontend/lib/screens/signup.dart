import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import "../config/app_config.dart";

class SignupWidget extends StatefulWidget {
  const SignupWidget({Key? key}) : super(key: key);

  @override
  State<SignupWidget> createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _socialSecurityFrontController = TextEditingController();
  final TextEditingController _socialSecurityBackController = TextEditingController();

  bool _passwordVisibility1 = false;
  bool _passwordVisibility2 = false;
  bool _isSingle = true;
  bool _hasChildren = false;
  bool _isLoading=false;

  Future<void> _signup() async {
    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
      );
      return;
    }
    setState(() {
      _isLoading=true;
    });
  }

  Future<void> _handleSignup() async {
    final Map<String, dynamic> signupData = {
      'login_id': _idController.text.trim(),
      'password': _passwordController.text.trim(),
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'birth': _getBirthFromSocialSecurity(),
      'is_male': true,
      'socialSecurity': _getSocialSecurity(),
      'is_married': _isSingle ? "true" : "false",
      'has_child': _hasChildren ? "true" : "false",
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(signupData),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final responseBody = jsonDecode(decodedBody);
        print('회원가입 성공!');
      } else {
        final decodedBody = utf8.decode(response.bodyBytes);
        final errorResponse = jsonDecode(decodedBody);
        print('회원가입 실패: ${errorResponse['detail']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: ${errorResponse['detail']}')),
        );
      }
    } catch (error) {
      print('오류 발생: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류 발생: $error')),
      );
    }finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getSocialSecurity() {
    final front = _socialSecurityFrontController.text.trim();
    final back = _socialSecurityBackController.text.trim();

    if (front.length != 6 || back.length != 1) {
      throw Exception('주민등록번호 형식이 올바르지 않습니다.');
    }

    if (front.isEmpty || back.isEmpty) {
      throw Exception('주민등록번호를 입력해주세요.');
    }

    return '$front-$back';
  }

  String _getBirthFromSocialSecurity() {
    final front = _socialSecurityFrontController.text.trim();

    if (front.length != 6 || int.tryParse(front) == null) {
      throw Exception('주민등록번호 앞자리(6자리)를 올바르게 입력하세요.');
    }

    // 생년월일 추출 (YYYY-MM-DD 형식으로 변환)
    final year = int.parse(front.substring(0, 2)); // 앞 2자리 (년도)
    final month = front.substring(2, 4); // 중간 2자리 (월)
    final day = front.substring(4, 6); // 마지막 2자리 (일)

    // 주민등록번호 뒷자리 첫 숫자로 세기 구분 (1,2=1900년대 / 3,4=2000년대)
    final back = _socialSecurityBackController.text.trim();
    if (back.isEmpty || int.tryParse(back) == null) {
      throw Exception('주민등록번호 뒷자리 첫 숫자를 올바르게 입력하세요.');
    }

    final century = (back.startsWith('1') || back.startsWith('2')) ? 1900 : 2000;

    return '${century + year}-$month-$day'; // 최종 생년월일 반환
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '환영합니다!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInputField('아이디', _idController, suffix: ElevatedButton(
                  onPressed: () {
                    print('중복확인');
                  },
                  child: const Text('중복확인'),
                )),
                _buildPasswordInputField('비밀번호', _passwordController, () {
                  setState(() {
                    _passwordVisibility1 = !_passwordVisibility1;
                  });
                }, _passwordVisibility1),
                _buildPasswordInputField('비밀번호 확인', _passwordConfirmController, () {
                  setState(() {
                    _passwordVisibility2 = !_passwordVisibility2;
                  });
                }, _passwordVisibility2),
                _buildInputField('이름', _nameController),
                _buildInputField('이메일', _emailController, keyboardType: TextInputType.emailAddress),
                _buildSocialSecurityField(),
                _buildCheckboxField('결혼여부', [
                  CheckboxListTile(
                    title: const Text('미혼'),
                    value: _isSingle,
                    onChanged: (value) {
                      setState(() {
                        _isSingle = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('기혼'),
                    value: !_isSingle,
                    onChanged: (value) {
                      setState(() {
                        _isSingle = !(value ?? false);
                      });
                    },
                  ),
                ]),
                _buildCheckboxField('자녀유무', [
                  CheckboxListTile(
                    title: const Text('유'),
                    value: _hasChildren,
                    onChanged: (value) {
                      setState(() {
                        _hasChildren = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('무'),
                    value: !_hasChildren,
                    onChanged: (value) {
                      setState(() {
                        _hasChildren = !(value ?? true);
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed('/homePage');
                      print('가입하기');
                      // 입력된 정보를 출력
                      print('아이디: ${_idController.text.trim()}');
                      print('비밀번호: ${_passwordController.text.trim()}');
                      print('비밀번호 확인: ${_passwordConfirmController.text.trim()}');
                      print('이름: ${_nameController.text.trim()}');
                      print('이메일: ${_emailController.text.trim()}');
                      print('주민등록번호: ${_socialSecurityFrontController.text.trim()}-${_socialSecurityBackController.text.trim()}');
                      print('결혼 여부: ${_isSingle ? "미혼" : "기혼"}');
                      print('자녀 유무: ${_hasChildren ? "유" : "무"}');

                      // 백엔드와 통신
                      _handleSignup();
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('가입하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, Widget? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: suffix,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPasswordInputField(String label, TextEditingController controller, VoidCallback toggleVisibility, bool visibility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !visibility,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: Icon(visibility ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleVisibility,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSocialSecurityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('주민등록번호'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _socialSecurityFrontController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  counterText: '',
                ),
                maxLength: 6,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-'),
            ),
            Expanded(
              child: TextField(
                controller: _socialSecurityBackController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  counterText: '',
                ),
                maxLength: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('******'),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCheckboxField(String label, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        ...options,
        const SizedBox(height: 16),
      ],
    );
  }
}
