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
    final questionState = ref.watch(questionProvider); // FutureProvider의 상태를 감시
    final questionNotifier = ref.read(questionProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: questionState.when(
            data: (questions) => _buildQuestionList(
              context,
              ref,
              questions?.questions ?? ["질문이 없습니다."],
              questionNotifier,
            ),
            loading: () => const CircularProgressIndicator(), // 로딩 상태 처리
            error: (error, stack) => Center(
              child: Text(
                '질문 데이터를 불러오는 중 오류가 발생했습니다.',
                style: const TextStyle(fontSize: 20, fontFamily: 'nanum'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionList(
      BuildContext context,
      WidgetRef ref,
      List<String> questions,
      QuestionNotifier questionNotifier,
      ) {
    final selectedIndex = questionNotifier.selectedIndex;

    return Column(
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
              ref.read(recordingServiceProvider).clearResponses(); // 녹음 응답 초기화
              Get.toNamed('/chat'); // 화면 이동
              print('${index + 1}번 질문 버튼이 클릭되었습니다.');
            },
          );
        }),
      ],
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
              ? Colors.green.shade300 // 활성화 상태 버튼 색상
              : const Color(0xFFC3E5AE), // 비활성화 버튼 색상
          elevation: 5,
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
