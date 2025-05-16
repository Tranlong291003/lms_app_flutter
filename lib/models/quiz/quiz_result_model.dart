class QuizResultModel {
  final int resultId;
  final String title;
  final bool passed;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int unansweredQuestions;
  final double score;
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
    required this.detailedResults,
    this.submittedAt,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    final questions = json['questions'] ?? json['detailedResults'] ?? [];
    final correct =
        json['total_correct_answers'] ?? json['correctAnswers'] ?? 0;
    final wrong = json['total_wrong_answers'] ?? json['incorrectAnswers'] ?? 0;
    final unanswered =
        (questions as List).where((q) => q['user_answer'] == null).length;
    return QuizResultModel(
      resultId: json['result_id'] ?? json['id'] ?? 0,
      title: (json['title'] ?? json['quiz_title'] ?? '').toString(),
      passed: json['passed'] == true,
      totalQuestions: questions.length,
      correctAnswers: correct,
      incorrectAnswers: wrong,
      unansweredQuestions: unanswered,
      score: (json['score'] ?? 0.0).toDouble(),
      detailedResults: questions,
      submittedAt:
          (json['submitted_at'] ?? json['submittedAt']) != null
              ? DateTime.tryParse(json['submitted_at'] ?? json['submittedAt'])
              : null,
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
