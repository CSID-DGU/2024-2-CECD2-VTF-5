import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/question.dart';

// 상태를 관리할 Notifier 클래스
class QuestionNotifier extends StateNotifier<List<Question>> {
  QuestionNotifier() : super([]);

  // 서버에서 데이터 호출 후 상태 업데이트
  Future<void> fetchQuestionsFromServer() async {
    // 서버에서 데이터를 호출 (여기서는 Mock 데이터 사용)
    await Future.delayed(Duration(seconds: 1));
    state = [
      Question(text: 'Question 1'),
      Question(text: 'Question 2'),
      Question(text: 'Question 3'),
    ];
  }

  // 사용자가 선택한 항목만 남기고 나머지 제거
  void selectQuestion(Question selectedQuestion) {
    state = [selectedQuestion];
  }

  // 상태 초기화
  void clearQuestions() {
    state = [];
  }
}

// Riverpod Provider
final questionProvider = StateNotifierProvider<QuestionNotifier, List<Question>>(
      (ref) => QuestionNotifier(),
);
