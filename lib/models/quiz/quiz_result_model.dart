import 'package:lms/apps/utils/json_parse.dart';

/// Kết quả một lượt làm bài.
///
/// Model này được dùng cho cả hai nguồn dữ liệu của API:
/// - `GET /api/quiz-results/users/:uid/results` — mỗi phần tử có
///   `result_id, title, score, passed, submitted_at`.
/// - `GET /api/quiz-results/:result_id` — chi tiết gồm `score, explanation,
///   total_correct_answers, total_wrong_answers, questions`.
class QuizResultModel {
  final int resultId;
  final String title;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double score;
  final String? explanation;
  final List<dynamic> detailedResults;
  final DateTime? submittedAt;

  const QuizResultModel({
    required this.resultId,
    required this.title,
    required this.passed,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.unansweredQuestions,
    required this.score,
    this.explanation,
    required this.detailedResults,
    this.submittedAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] ?? json['detailedResults'];
    final questionList = questions is List ? questions : const [];

    final correct = asInt(
      json['total_correct_answers'] ?? json['correctAnswers'],
    );
    final wrong = asInt(json['total_wrong_answers'] ?? json['incorrectAnswers']);
    final unanswered = questionList
        .where((q) => q is Map && q['user_answer'] == null)
        .length;

    return QuizResultModel(
      resultId: asInt(json['result_id'] ?? json['id']),
      title: asString(json['title'] ?? json['quiz_title']),
      passed: asBool(json['passed']),
      // Ở danh sách không có mảng questions → suy ra tổng số câu đã chấm.
      totalQuestions: questionList.isNotEmpty
          ? questionList.length
          : correct + wrong,
      correctAnswers: correct,
      incorrectAnswers: wrong,
      unansweredQuestions: unanswered,
      score: asDouble(json['score']),
      explanation: asStringOrNull(json['explanation']),
      detailedResults: questionList,
      submittedAt: asDateTime(json['submitted_at'] ?? json['submittedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'title': title,
      'passed': passed,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'unansweredQuestions': unansweredQuestions,
      'score': score,
      'explanation': explanation,
      'detailedResults': detailedResults,
      'submitted_at': submittedAt?.toIso8601String(),
    };
  }

  // Thống kê số liệu các câu trả lời
  Map<String, int> get answerStats => {
    'total': totalQuestions,
    'correct': correctAnswers,
    'incorrect': incorrectAnswers,
    'unanswered': unansweredQuestions,
  };

  // Tính phần trăm câu đúng
  double get percentageCorrect =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  // Tính phần trăm câu sai
  double get percentageIncorrect =>
      totalQuestions > 0 ? (incorrectAnswers / totalQuestions) * 100 : 0;

  // Tính phần trăm câu chưa trả lời
  double get percentageUnanswered =>
      totalQuestions > 0 ? (unansweredQuestions / totalQuestions) * 100 : 0;
}
