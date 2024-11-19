import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LostPWWidget extends StatefulWidget {
  const LostPWWidget({Key? key}) : super(key: key);

  @override
  State<LostPWWidget> createState() => _LostPWWidgetState();
}

class _LostPWWidgetState extends State<LostPWWidget> {
  final TextEditingController _textController = TextEditingController(text: '이메일을 입력해주세요.');
  final FocusNode _textFieldFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.background,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 200),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/password.png',
                    width: 200,height: 200,),
                ),
                SizedBox(height: 50),
                Text(
                  '비밀번호를 잊으셨나요?',
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 30,
                  fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  '이메일을 통해 비밀번호 변경을 위한\n인증번호가 전송됩니다.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)
                ),
                SizedBox(height: 30),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _textController,
                    focusNode: _textFieldFocusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '이메일을 입력해주세요.',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFC3E5AE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFC3E5AE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: theme.textTheme.bodyMedium,
                    cursorColor: theme.colorScheme.onBackground,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed('/verificationCode');
                    print('이메일 전송 버튼 클릭됨');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 40),
                    backgroundColor: Color(0xFFC3E5AE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '이메일 전송',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
