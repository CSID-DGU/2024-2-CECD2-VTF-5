import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsesNotifier extends StateNotifier<List<String>> {
  ResponsesNotifier() : super([]);

  // 응답 추가
  void addResponse(String response) {
    state = [...state, response];
  }

  // 응답 리스트 초기화
  void clearResponses() {
    state = [];
  }
}
