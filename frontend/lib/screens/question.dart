import 'package:flutter/material.dart';

class questionWidget extends StatefulWidget {
  const questionWidget({Key? key}) : super(key: key);

  @override
  State<questionWidget> createState() => _questionWidgetState();
}

class _questionWidgetState extends State<questionWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '어떤 질문에 답변 하시겠습니까?',
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'nanum',
                  ),
                ),
                _buildButton(context, '1. input', () {
                  print('1번 버튼이 클릭되었습니다.');
                }),
                _buildButton(context, '2. input', () {
                  print('2번 버튼이 클릭되었습니다.');
                }),
                _buildButton(context, '3. input', () {
                  print('3번 버튼이 클릭되었습니다.');
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: const Color(0xFFC3E5AE),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'nanum',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
