import 'dart:math';

import 'package:intl/intl.dart';
import 'package:lms/apps/utils/json_parse.dart';

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
  final double passingRate;

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
    this.passingRate = 0.0,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    // `COUNT()` và `NUMERIC` của PostgreSQL trả về dạng chuỗi trong JSON.
    final questions = json['questions'];

    return QuizModel(
      quizId: asInt(json['quiz_id']),
      title: asString(json['title']),
      description: asStringOrNull(json['description']),
      type: asString(json['type'], 'trac_nghiem'),
      timeLimit: asInt(json['time_limit']),
      attemptLimit: asInt(json['attempt_limit']),
      creatorUid: asString(json['creator_uid']).trim(),
      createdAt: asDateTimeOr(json['created_at'], DateTime.now()),
      updatedAt: asDateTime(json['updated_at']),
      attemptsUsed: asIntOrNull(json['attempts_used']),
      questions: questions is List
          ? questions
                .map(
                  (q) => QuestionModel.fromJson(
                    Map<String, dynamic>.from(q as Map),
                  ),
                )
                .toList()
          : null,
      totalQuestions: asInt(json['total_questions']),
      averageScore: asDouble(json['average_score']),
      passingRate: asDouble(json['passing_rate']),
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

  /// Nhãn hiển thị. API dùng `trac_nghiem` | `tu_luan` (có nhận thêm các giá
  /// trị cũ để tương thích dữ liệu đã tồn tại).
  String get displayType {
    switch (type) {
      case 'trac_nghiem':
      case 'multiple_choice':
        return 'Trắc nghiệm';
      case 'tu_luan':
      case 'essay':
        return 'Tự luận';
      case 'true_false':
        return 'Đúng/Sai';
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
