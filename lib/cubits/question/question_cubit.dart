import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/repository/question_repository.dart';

enum QuestionStatus { initial, loading, loaded, error, submitted }

class QuestionState {
  final QuestionStatus status;
  final List<QuestionModel> questions;
  final List<int> userAnswers;
  final int? selectedQuestionIndex;
  final bool isQuizSubmitted;
  final String? errorMessage;
  final Map<String, dynamic>? quizResult;

  QuestionState({
    this.status = QuestionStatus.initial,
    this.questions = const [],
    this.userAnswers = const [],
    this.selectedQuestionIndex,
    this.isQuizSubmitted = false,
    this.errorMessage,
    this.quizResult,
  });

  QuestionState copyWith({
    QuestionStatus? status,
    List<QuestionModel>? questions,
    List<int>? userAnswers,
    int? selectedQuestionIndex,
    bool? isQuizSubmitted,
    String? errorMessage,
    Map<String, dynamic>? quizResult,
  }) {
    return QuestionState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      userAnswers: userAnswers ?? this.userAnswers,
      selectedQuestionIndex:
          selectedQuestionIndex ?? this.selectedQuestionIndex,
      isQuizSubmitted: isQuizSubmitted ?? this.isQuizSubmitted,
      errorMessage: errorMessage ?? this.errorMessage,
      quizResult: quizResult ?? this.quizResult,
    );
  }

  bool isQuestionAnswered(int index) {
    return index >= 0 && index < userAnswers.length && userAnswers[index] >= 0;
  }
}

class QuestionCubit extends Cubit<QuestionState> {
  final QuestionRepository _repository;

  QuestionCubit(this._repository) : super(QuestionState());

  Future<void> loadQuestionsByQuizId(
    int quizId, {
    QuizModel? quizInfo,
    int? maxQuestions,
  }) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    try {
      // Nếu có quizInfo và có sẵn câu hỏi, sử dụng random questions
      if (quizInfo != null &&
          quizInfo.questions != null &&
          quizInfo.questions!.isNotEmpty) {
        final random = quizInfo.questions!..shuffle();
        final randomQuestions =
            maxQuestions != null && random.length > maxQuestions
                ? random.take(maxQuestions).toList()
                : random;
        emit(
          state.copyWith(
            status: QuestionStatus.loaded,
            questions: randomQuestions,
            userAnswers: List.filled(randomQuestions.length, -1),
          ),
        );
        return;
      }
      // Nếu không có sẵn câu hỏi, tải từ API
      final questions = await _repository.getQuestionsByQuizId(
        quizId,
        maxQuestions: maxQuestions,
      );
      emit(
        state.copyWith(
          status: QuestionStatus.loaded,
          questions: questions,
          userAnswers: List.filled(questions.length, -1),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void selectQuestion(int index) {
    if (index >= 0 && index < state.questions.length) {
      emit(state.copyWith(selectedQuestionIndex: index));
    }
  }

  void selectAnswer(int questionIndex, int answerIndex) {
    if (questionIndex >= 0 &&
        questionIndex < state.questions.length &&
        answerIndex >= 0 &&
        answerIndex < state.questions[questionIndex].options.length) {
      final newAnswers = List<int>.from(state.userAnswers);
      newAnswers[questionIndex] = answerIndex;
      emit(state.copyWith(userAnswers: newAnswers));
    }
  }

  void nextQuestion() {
    if (state.selectedQuestionIndex != null &&
        state.selectedQuestionIndex! < state.questions.length - 1) {
      emit(
        state.copyWith(selectedQuestionIndex: state.selectedQuestionIndex! + 1),
      );
    }
  }

  void previousQuestion() {
    if (state.selectedQuestionIndex != null &&
        state.selectedQuestionIndex! > 0) {
      emit(
        state.copyWith(selectedQuestionIndex: state.selectedQuestionIndex! - 1),
      );
    }
  }

  void reset() {
    emit(QuestionState());
  }

  int getUserAnswer(int questionIndex) {
    if (questionIndex >= 0 && questionIndex < state.userAnswers.length) {
      return state.userAnswers[questionIndex];
    }
    return -1;
  }

  int getCorrectAnswersCount() {
    int count = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (state.userAnswers[i] == state.questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  double getScore() {
    if (state.questions.isEmpty) return 0;
    final correctAnswers = getCorrectAnswersCount();
    return (correctAnswers / state.questions.length) * 10;
  }

  Future<Map<String, dynamic>> submitQuizResult(
    int quizId,
    String userUid,
    Map<String, int?> answers, {
    String? explanation,
  }) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    try {
      final result = await _repository.submitQuizResult(
        quizId,
        userUid,
        answers,
        state.questions,
        explanation: explanation,
      );
      emit(
        state.copyWith(
          status: QuestionStatus.submitted,
          isQuizSubmitted: true,
          quizResult: result,
        ),
      );
      return result;
    } catch (e) {
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return {'success': false, 'message': e.toString()};
    }
  }
}
