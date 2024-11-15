import 'package:flutter/material.dart';

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
                      print('가입하기');
                    },
                    child: const Text('가입하기'),
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
