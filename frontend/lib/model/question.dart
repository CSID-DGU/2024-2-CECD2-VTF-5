import 'package:flutter/foundation.dart';

class QuestionModel {
  final List<String> questions;

  QuestionModel({required this.questions});

  factory QuestionModel.fromList(List<dynamic> jsonList) {
    return QuestionModel(
      questions: List<String>.from(jsonList),
    );
  }
}


