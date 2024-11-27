import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:vtfecho/model/question.dart';
import '../services/recording_service.dart';
import '../provider/question_provider.dart';
import '../provider/responsesProvider.dart';
import '../provider/recordingServiceProvider.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ChatWidget extends ConsumerStatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends ConsumerState<ChatWidget> {
  late ChatModel _model;
  late RecordingService _recordingService;
  bool isRecording = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FlutterTts tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _model = ChatModel();

    tts.setLanguage("ko-KR");
    tts.setSpeechRate(0.5); // 속도
    tts.setVolume(0.6); // 볼륨
    tts.setPitch(1); // 음높이
  }


  void didChangeDependencies() {
    super.didChangeDependencies();
    _recordingService = ref.read(recordingServiceProvider);
  }

  @override
  void dispose() {
    _model.dispose();
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Provider에서 선택된 질문 가져오기
    final questionNotifier = ref.read(questionProvider.notifier);
    final selectedQuestion = questionNotifier.getSelectedQuestion() ?? '질문이 선택되지 않았습니다.';

    final responses = ref.watch(responsesProvider);


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
              // 질문창
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
                      child: GestureDetector(
                        onTap: () => _speak(selectedQuestion),
                        child: Image.asset('assets/images/stt.png',
                        width: 70,height: 70,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        // padding: const EdgeInsets.only(left: 20, right: 20),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: SingleChildScrollView(
                          child: Text(
                            selectedQuestion,
                            style: TextStyle(
                              fontFamily: 'nanum',
                              fontSize: screenWidth * 0.08,
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
                  // 답변창
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
                                responses.join('\n'),
                                style: TextStyle(
                                  fontFamily: 'nanum',
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.w700
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
                            Get.toNamed('/home');
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
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.w600
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
                                Get.toNamed('/nextQuestoin');
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
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w600
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

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await tts.speak(text);
    }
  }
}

class ChatModel {
  void dispose() {
    // Add any necessary cleanup code here.
  }
}
