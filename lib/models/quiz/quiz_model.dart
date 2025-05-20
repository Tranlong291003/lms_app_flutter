import 'dart:math';

import 'package:intl/intl.dart';

import 'question_model.dart';

enum QuizDurationType {
  fifteenMinutes(15, 15),
  thirtyMinutes(30, 30),
  oneHour(60, 50),
  ninetyMinutes(90, 75);

  final int minutes;
  final int questionCount;
  const QuizDurationType(this.minutes, this.questionCount);

  static QuizDurationType fromMinutes(int minutes) {
    switch (minutes) {
      case 15:
        return QuizDurationType.fifteenMinutes;
      case 30:
        return QuizDurationType.thirtyMinutes;
      case 60:
        return QuizDurationType.oneHour;
      case 90:
        return QuizDurationType.ninetyMinutes;
      default:
        return QuizDurationType.thirtyMinutes;
    }
  }
}

class QuizModel {
  final int quizId;
  final String title;
  final String? description;
  final String type;
  final int timeLimit;
  final int attemptLimit;
  final String creatorUid;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? attemptsUsed;
  final List<QuestionModel>? questions;
  final int totalQuestions;
  final double averageScore;

  const QuizModel({
    required this.quizId,
    required this.title,
    this.description,
    required this.type,
    required this.timeLimit,
    required this.attemptLimit,
    required this.creatorUid,
    required this.createdAt,
    this.updatedAt,
    this.attemptsUsed,
    this.questions,
    this.totalQuestions = 0,
    this.averageScore = 0.0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    int totalQuestions = 0;
    double averageScore = 0.0;
    // Xử lý an toàn cho total_questions
    if (json['total_questions'] is int) {
      totalQuestions = json['total_questions'] as int;
    } else if (json['total_questions'] is String) {
      totalQuestions = int.tryParse(json['total_questions']) ?? 0;
    }
    // Xử lý an toàn cho average_score
    if (json['average_score'] is int) {
      averageScore = (json['average_score'] as int).toDouble();
    } else if (json['average_score'] is double) {
      averageScore = json['average_score'] as double;
    } else if (json['average_score'] is String) {
      averageScore = double.tryParse(json['average_score']) ?? 0.0;
    } else if (json['average_score'] is num) {
      averageScore = (json['average_score'] as num).toDouble();
    }
    return QuizModel(
      quizId: json['quiz_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      timeLimit: json['time_limit'] as int,
      attemptLimit: json['attempt_limit'] as int,
      creatorUid: (json['creator_uid'] as String).trim(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      attemptsUsed: json['attempts_used'] as int?,
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((q) => QuestionModel.fromJson(q))
                  .toList()
              : null,
      totalQuestions: totalQuestions,
      averageScore: averageScore,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'title': title,
      'description': description,
      'type': type,
      'time_limit': timeLimit,
      'attempt_limit': attemptLimit,
      'creator_uid': creatorUid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'attempts_used': attemptsUsed,
      'questions': questions?.map((q) => q.toJson()).toList(),
      'total_questions': totalQuestions,
      'average_score': averageScore,
    };
  }

  String get formattedCreatedAt {
    return DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  }

  String get formattedUpdatedAt {
    return updatedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(updatedAt!)
        : '';
  }

  String get displayType {
    switch (type) {
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'true_false':
        return 'Đúng/Sai';
      case 'essay':
        return 'Tự luận';
      default:
        return type;
    }
  }

  QuizDurationType get durationType {
    return QuizDurationType.fromMinutes(timeLimit);
  }

  List<QuestionModel> getRandomQuestions() {
    if (questions == null || questions!.isEmpty) {
      return [];
    }

    final random = Random();
    final shuffledQuestions = List<QuestionModel>.from(questions!);
    shuffledQuestions.shuffle(random);

    final questionCount = durationType.questionCount;
    if (shuffledQuestions.length > questionCount) {
      return shuffledQuestions.take(questionCount).toList();
    }

    return shuffledQuestions;
  }
}
