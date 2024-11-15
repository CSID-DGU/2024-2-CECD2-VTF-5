import 'package:flutter/material.dart';
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
                                '아이고, 그걸 이야기하자면 참 긴 얘기야. 우리 시절엔 요즘처럼 자유롭게 만남을 가질 수 있는 것도 아니었고, 사람을 만나고 싶다고 해도 쉽지 않았거든. 옛날 친구가 홀로 지낸 세월이 좀 오래됐는데, 나이가 들수록 혼자라는 게 더 외롭잖아. 아침에 일어나서 아무도 없는 집에 앉아있을 때의 그 쓸쓸함이란 나도 그 마음을 잘 알지. 그래서 나처럼 혼자인 친구가 편안하게 대화할 사람이라도 있으면 얼마나 좋을까 싶었어. 같이 시장에도 가고, 맛있는 음식도 나눠 먹으면서 웃을 수 있는',
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
                            Navigator.pushNamed(context, 'HomePage');
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
                            Icon(
                              Icons.navigate_next_rounded,
                              color: Colors.black,
                              size: 24,
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
