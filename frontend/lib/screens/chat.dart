import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xFFC3E5AE),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Image.asset('assets/icons/QuestionBoy.png',
                        width: 70,height: 70,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        '그렇다면 작성자님은 어떤 이유로\n친구에게 소개팅을 주선했나요?',
                        style: TextStyle(
                          fontFamily: 'nanum',
                          fontSize: 32,
                          fontWeight: FontWeight.normal
                        ),
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
                              color: Color(0xFFFFBC8C),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _recordingService.responses.join('\n'),
                                // '답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!\n답변입니다!',
                                style: TextStyle(
                                  fontFamily: 'nanum',
                                  fontSize: 30,
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
                                  fontFamily: 'nanum',
                                  fontSize: 16,
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
                                List<String>? questions = await _recordingService.sendResponsesToServer();
                                if (questions != null && questions.isNotEmpty) {
                                  // 질문 리스트 출력
                                  String? question1 = questions.length > 0
                                      ? questions[0]
                                      : null;
                                  String? question2 = questions.length > 1
                                      ? questions[1]
                                      : null;
                                  String? question3 = questions.length > 2
                                      ? questions[2]
                                      : null;
                                  print("Question 1: $question1 \nQuestion 2: $question1\nQuestion 3: $question3");
                                }
                                else {
                                  print("질문을 받아오지 못했습니다.");
                                }
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
                                fontFamily: 'nanum',
                                fontSize: 16,
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
