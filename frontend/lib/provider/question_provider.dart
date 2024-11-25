import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/question.dart';
import '../services/recording_service.dart';
import './recordingServiceProvider.dart';

final questionProvider =
StateNotifierProvider<QuestionNotifier, QuestionModel?>((ref) {
  final questionNotifier = QuestionNotifier(ref);
  questionNotifier.fetchInitialData(); // 초기 데이터를 비동기로 가져옵니다.
  return questionNotifier;
});


class QuestionNotifier extends StateNotifier<QuestionModel?> {
  final Ref ref;

  QuestionNotifier(this.ref) : super(null){
    print("QuestionNotifier 초기화됨");
  }

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  Future<void> fetchInitialData() async {
    print("fetchInitialData() 호출됨"); // 확인 로그
    try {
      // recordingService를 사용해 서버에서 데이터 가져오기
      final recordingService = ref.read(recordingServiceProvider);
      final questionModel = await recordingService.sendResponsesToServer();

      // 상태 업데이트
      state = questionModel;
      print("Updated State in Provider: ${state?.questions}");
    } catch (e) {
      // 오류 발생 시 기본 데이터 설정
      state = QuestionModel(questions: ["서버 데이터를 불러올 수 없습니다."]);
      print("Error fetching questions: $e");
    }
  }

  void selectQuestion(int index) {
    _selectedIndex = index;
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
