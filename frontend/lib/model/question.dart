import 'package:flutter/foundation.dart';

class QuestionModel {
  final List<String> questions;

  QuestionModel({required this.questions});

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      questions: List<String>.from(json['questions']),
    );
  }
}
