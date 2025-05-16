import 'dart:convert';

import 'package:intl/intl.dart';

class QuestionModel {
  final int questionId;
  final int quizId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? expectedKeywords;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const QuestionModel({
    required this.questionId,
    required this.quizId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.expectedKeywords,
    required this.createdAt,
    this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    List<String> optionsList = [];

    if (json['options'] != null) {
      // Xử lý options lưu dạng JSON string
      if (json['options'] is String) {
        try {
          optionsList = List<String>.from(jsonDecode(json['options']));
        } catch (e) {
          print('Lỗi khi parse options: $e');
          optionsList = [];
        }
      }
      // Trường hợp options đã là một mảng
      else if (json['options'] is List) {
        optionsList = List<String>.from(json['options']);
      }
    }

    return QuestionModel(
      questionId: json['question_id'],
      quizId: json['quiz_id'],
      question: json['question'],
      options: optionsList,
      correctIndex: json['correct_index'],
      expectedKeywords: json['expected_keywords'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'quiz_id': quizId,
      'question': question,
      'options': jsonEncode(options),
      'correct_index': correctIndex,
      'expected_keywords': expectedKeywords,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String getFormattedCreatedDate() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(createdAt);
  }

  String? getFormattedUpdatedDate() {
    if (updatedAt == null) return null;
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(updatedAt!);
  }

  String getCorrectAnswer() {
    if (options.isEmpty || correctIndex >= options.length) {
      return "Không có đáp án";
    }
    return options[correctIndex];
  }
}

class AnswerOption {
  final int optionId;
  final String content;
  final bool isCorrect;

  const AnswerOption({
    required this.optionId,
    required this.content,
    required this.isCorrect,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) {
    return AnswerOption(
      optionId: json['option_id'],
      content: json['content'],
      isCorrect: json['is_correct'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'option_id': optionId, 'content': content, 'is_correct': isCorrect};
  }
}
