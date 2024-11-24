import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/question.dart';
import '../services/recording_service.dart';

final questionProvider = StateNotifierProvider<QuestionNotifier, QuestionModel?>(
      (ref) => QuestionNotifier()..fetchInitialData(), // 초기 데이터 로드
);

class QuestionNotifier extends StateNotifier<QuestionModel?> {
  QuestionNotifier() : super(null);

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  void fetchInitialData() {
    state = QuestionModel(questions: [
      "질문 1",
      "질문 2",
      "질문 3",
    ]);
  }

  void selectQuestion(int index){
    _selectedIndex=index;
  }

  String? getSelectedQuestion() {
    if (state == null || _selectedIndex == null) return null;
    return getQuestion(_selectedIndex!);
  }

  String getQuestion(int index) {
    if (state == null || index < 0 || index >= state!.questions.length) {
      return "질문이 없습니다.";
    }
    return state!.questions[index];
  }
}

