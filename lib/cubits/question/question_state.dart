import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';

enum QuestionStatus { initial, loading, loaded, error }

enum AnswerStatus { unanswered, answered }

class QuestionState {
  final QuestionStatus status;
  final List<QuestionModel> questions;
  final QuizModel? quizInfo;
  final String errorMessage;
  final bool isLoading;
  final int? selectedQuestionIndex;
  final List<int> userAnswers;
  final bool isQuizSubmitted;
  final QuizResultModel? quizResult;

  QuestionState({
    this.status = QuestionStatus.initial,
    this.questions = const [],
    this.quizInfo,
    this.errorMessage = '',
    this.isLoading = false,
    this.selectedQuestionIndex,
    this.userAnswers = const [],
    this.isQuizSubmitted = false,
    this.quizResult,
  });

  QuestionState copyWith({
    QuestionStatus? status,
    List<QuestionModel>? questions,
    QuizModel? quizInfo,
    String? errorMessage,
    bool? isLoading,
    int? selectedQuestionIndex,
    List<int>? userAnswers,
    bool? isQuizSubmitted,
    QuizResultModel? quizResult,
  }) {
    return QuestionState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      quizInfo: quizInfo ?? this.quizInfo,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      selectedQuestionIndex:
          selectedQuestionIndex ?? this.selectedQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      isQuizSubmitted: isQuizSubmitted ?? this.isQuizSubmitted,
      quizResult: quizResult ?? this.quizResult,
    );
  }

  bool get hasQuestions => questions.isNotEmpty;
  int get totalQuestions => questions.length;

  QuestionModel? get currentQuestion {
    if (selectedQuestionIndex != null &&
        selectedQuestionIndex! >= 0 &&
        selectedQuestionIndex! < questions.length) {
      return questions[selectedQuestionIndex!];
    }
    return null;
  }

  int? getUserAnswer(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < userAnswers.length) {
      return userAnswers[questionIndex] >= 0
          ? userAnswers[questionIndex]
          : null;
    }
    return null;
  }

  bool isQuestionAnswered(int questionIndex) {
    return getUserAnswer(questionIndex) != null;
  }

  int getCorrectAnswersCount() {
    int count = 0;
    for (int i = 0; i < questions.length; i++) {
      final userAnswer = getUserAnswer(i);
      if (userAnswer != null && userAnswer == questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  double getScore() {
    if (questions.isEmpty) return 0;
    return (getCorrectAnswersCount() / questions.length) * 10;
  }

  AnswerStatus getQuestionStatus(int index) {
    if (index < 0 ||
        index >= questions.length ||
        userAnswers.isEmpty ||
        index >= userAnswers.length) {
      return AnswerStatus.unanswered;
    }
    return userAnswers[index] >= 0
        ? AnswerStatus.answered
        : AnswerStatus.unanswered;
  }

  bool get allQuestionsAnswered {
    if (userAnswers.isEmpty || userAnswers.length != questions.length)
      return false;
    return !userAnswers.contains(-1);
  }
}
