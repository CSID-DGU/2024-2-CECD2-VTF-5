import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vtfecho/model/question.dart';
import '../services/recording_service.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late ChatModel _model;
  late RecordingService _recordingService;
  bool isRecording = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = ChatModel();
    _recordingService = RecordingService();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.15,
                decoration: BoxDecoration(
                  color: Color(0xFFB1EBB3),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Image.asset('assets/images/stt.png',
                        width: 70,height: 70,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        // padding: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(
                          child: Text(
                            '그렇다면 작성자님은 어떤 이유로 친구에게 소개팅을 주선했나요? 질문길면 스크롤 질문길면 스크롤 질문길면 스크롤 질문길면 스크롤 질문길면 스크롤 ㅅㅋㄹㅅㅋㄹㅅㅋㄹ',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        )
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFCFAD),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _recordingService.responses.join('\n'),
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: GestureDetector(
                      onTap: _toggleRecording,
                      child: Image.asset(
                        isRecording
                        ? 'assets/images/Listening.png'
                        : 'assets/images/Listening2.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Column(
                            children: [
                              Icon(
                                Icons.home,
                                color: Colors.black,
                                size: 24,
                              ),
                              Text(
                                '홈화면',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async{
                                _recordingService.sendResponsesToServer();
                                Get.toNamed('/question');
                              },
                              child: Icon(
                                Icons.navigate_next_rounded,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            Text(
                              '다음질문',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_recordingService.isRecording) {
      await _recordingService.stopRecording();
    } else {
      await _recordingService.startRecording();
    }
    setState(() {
      isRecording = _recordingService.isRecording;
    });
  }
}

class ChatModel {
  void dispose() {
    // Add any necessary cleanup code here.
  }
}
