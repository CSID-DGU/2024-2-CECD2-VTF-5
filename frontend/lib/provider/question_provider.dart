import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/question.dart';

final questionProvider = StateNotifierProvider<QuestionNotifier, QuestionModel?>(
      (ref) => QuestionNotifier(),
);

class QuestionNotifier extends StateNotifier<QuestionModel?> {
  QuestionNotifier() : super(null);

  // 서버에서 데이터를 받아와 모델에 저장
  Future<void> fetchQuestions(Map<String, dynamic> jsonData) async {
    final model = QuestionModel.fromJson(jsonData);
    state = model;
  }

  // 특정 번호의 질문을 선택
  String getQuestion(int index) {
    if (state == null || index < 0 || index >= (state?.questions.length ?? 0)) {
      return '질문이 없습니다.';
    }
    return state!.questions[index];
  }
}
