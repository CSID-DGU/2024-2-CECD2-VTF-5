import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/recording_service.dart';
import '../provider/question_provider.dart';

class nextquestionWidget extends StatefulWidget {
  const nextquestionWidget({Key? key}) : super(key: key);

  @override
  State<nextquestionWidget> createState() => _nextquestionWidgetState();
}

class _nextquestionWidgetState extends State<nextquestionWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late RecordingService _recordingService;

  @override
  void initState() {
    super.initState();
    _recordingService = RecordingService();
  }

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
                _buildButton(context, '유사한\n질문받기', () {
                  _recordingService.sendResponsesToServer();
                  Get.toNamed('/question');
                }),
                _buildButton(context, '다른\n질문받기', () {
                  _recordingService.sendResponsesToServer();
                  Get.toNamed('/question');
                }),
                _buildButton(context, '답변\n계속하기', () {
                  Navigator.pop(context);
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
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 45,
            fontFamily: 'nanum',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
