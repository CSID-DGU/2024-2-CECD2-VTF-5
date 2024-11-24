import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/recording_service.dart';
import '../provider/question_provider.dart';

class QuestionWidget extends ConsumerWidget {
  const QuestionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final RecordingService recordingService = RecordingService();
    final questionNotifier = ref.read(questionProvider.notifier);
    final selectedIndex = ref.watch(questionProvider.notifier).selectedIndex;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                ),
                // 버튼 1
                _buildButton(
                  context,
                  questionNotifier.getQuestion(0), // 첫 번째 질문
                  selectedIndex == 0, // 버튼 활성화 상태 확인
                      () {
                    questionNotifier.selectQuestion(0); // 선택 상태 업데이트
                    recordingService.clearResponses();
                    Get.toNamed('/chat');
                    print('1번 질문 버튼이 클릭되었습니다.');
                  },
                ),
                // 버튼 2
                _buildButton(
                  context,
                  questionNotifier.getQuestion(1), // 두 번째 질문
                  selectedIndex == 1, // 버튼 활성화 상태 확인
                      () {
                    questionNotifier.selectQuestion(1); // 선택 상태 업데이트
                    recordingService.clearResponses();
                    Get.toNamed('/chat');
                    print('2번 질문 버튼이 클릭되었습니다.');
                  },
                ),
                // 버튼 3
                _buildButton(
                  context,
                  questionNotifier.getQuestion(2), // 세 번째 질문
                  selectedIndex == 2, // 버튼 활성화 상태 확인
                      () {
                    questionNotifier.selectQuestion(2); // 선택 상태 업데이트
                    recordingService.clearResponses();
                    Get.toNamed('/chat');
                    print('3번 질문 버튼이 클릭되었습니다.');
                  },
                ),
              ],
            ),
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
          backgroundColor: isSelected
              ? const Color(0xFF82C3E5) // 선택된 버튼 색상
              : const Color(0xFFC3E5AE), // 기본 버튼 색상
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 30,
            fontFamily: 'nanum',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
