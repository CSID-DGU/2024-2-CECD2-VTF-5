import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording_service.dart';
import '../provider/question_provider.dart';
import '../provider/recordingServiceProvider.dart';

class QuestionWidget extends ConsumerWidget {
  const QuestionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingService = ref.read(recordingServiceProvider);
    final questionState = ref.watch(questionProvider);
    final questionNotifier = ref.read(questionProvider.notifier);
    final selectedIndex = questionNotifier.selectedIndex;

    print("Current Question State in UI: ${questionState?.questions}");

    // 질문 리스트
    final questions = questionState?.questions ?? ["질문을 생성 중 입니다."];

    if (questionState == null) {
      Future.delayed(const Duration(seconds: 5), () {
        // 상태가 null일 경우만 초기화
        questionNotifier.fetchInitialData();
      });
    }

    // questionNotifier.fetchInitialData(); //강제호출(비상탈출)

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '어떤 질문에 답변 하시겠습니까?',
                style: TextStyle(
                  fontSize: 40,
                  fontFamily: 'nanum',
                ),
                textAlign: TextAlign.center,
              ),
              ...List.generate(questions.length, (index) {
                return _buildButton(
                  context,
                  questions[index], // 각 질문 텍스트
                  selectedIndex == index, // 활성화 상태
                      () {
                    questionNotifier.selectQuestion(index); // 질문 선택
                    recordingService.clearResponses(); // 녹음 응답 초기화
                    Get.toNamed('/chat'); // 화면 이동
                    print('${index + 1}번 질문 버튼이 클릭되었습니다.');
                  },
                );
              }),
              // 로딩 중일 경우 스피너
              if (questionState == null)
                CircularProgressIndicator(), // 로딩 표시
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String text, bool isSelected, VoidCallback onPressed) {
    return SizedBox(
      width: 300,
      height: 150,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: const Color(0xFFC3E5AE),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 25,
            fontFamily: 'nanum',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}