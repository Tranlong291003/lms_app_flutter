import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/repositories/question_repository.dart';

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

  /// Câu trả lời của người dùng; `null` khi chưa trả lời.
  int? getUserAnswer(int index) {
    if (index >= 0 && index < userAnswers.length && userAnswers[index] >= 0) {
      return userAnswers[index];
    }
    return null;
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
      if (isClosed) return;
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

  /// Số câu trả lời đúng theo dữ liệu ĐÃ TẢI.
  ///
  /// Chỉ dùng khi không có kết quả chính thức từ server (xem [serverScore]).
  ///
  /// Hai điều kiện đều bắt buộc:
  /// - Câu phải được trả lời. `userAnswers` khởi tạo bằng `-1` cho mọi câu, và
  ///   một số quiz (dữ liệu cũ) không có `correct_index` nên model mặc định
  ///   cũng là `-1` → so sánh `-1 == -1` tính câu BỎ TRỐNG là đúng.
  /// - `correctIndex` phải hợp lệ (>= 0). Cùng lý do trên, `-1` nghĩa là "không
  ///   có đáp án đúng trong dữ liệu", không phải một đáp án.
  int getCorrectAnswersCount() {
    int count = 0;
    for (int i = 0; i < state.questions.length; i++) {
      final userAnswer = state.getUserAnswer(i);
      if (userAnswer != null && userAnswer == state.questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  /// Điểm do server chấm (`POST /api/quiz-results/submit` trả `score` thang 10).
  ///
  /// Server là nguồn chân lý: nó tính trên đúng tập câu đã gửi và trả cả
  /// `correct_answers`. Trả `null` khi chưa nộp bài.
  double? get serverScore {
    final value = state.quizResult?['score'];
    if (value is num) return value.toDouble();
    return null;
  }

  /// Số câu đúng do server chấm, `null` nếu chưa nộp bài.
  int? get serverCorrectAnswers {
    final raw = state.quizResult?['data'];
    final value = raw is Map ? raw['correctAnswers'] : null;
    if (value is num) return value.toInt();
    return null;
  }

  /// Số câu đã trả lời (dùng để chấm điểm dự phòng khi server không trả điểm).
  int get answeredCount {
    int count = 0;
    for (int i = 0; i < state.questions.length; i++) {
      if (state.getUserAnswer(i) != null) count++;
    }
    return count;
  }

  /// Điểm dự phòng khi server không trả `score`.
  ///
  /// Công thức theo API: `correct / totalAnswered * 10` — chia cho số câu ĐÃ
  /// TRẢ LỜI, không phải tổng số câu (bỏ trống không bị trừ điểm).
  double getScore() {
    final answered = answeredCount;
    if (answered == 0) return 0;
    return (getCorrectAnswersCount() / answered) * 10;
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
      if (isClosed) return {'success': false, 'message': 'Đã huỷ'};
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<bool> updateQuestion(
    int questionId,
    Map<String, dynamic> data,
    int quizId,
  ) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    final result = await _repository.updateQuestion(questionId, data);
    if (result) {
      await loadQuestionsByQuizId(quizId);
      if (isClosed) return false;
      emit(state.copyWith(status: QuestionStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: 'Cập nhật câu hỏi thất bại',
        ),
      );
    }
    return result;
  }

  Future<bool> deleteQuestion(
    int questionId,
    Map<String, dynamic> data,
    int quizId,
  ) async {
    final result = await _repository.deleteQuestion(questionId, data);
    return result;
  }

  /// Tạo câu hỏi bằng tay
  Future<bool> createQuestionManual(
    Map<String, dynamic> data,
    int quizId,
  ) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    final result = await _repository.createQuestionManual(data);
    if (result) {
      await loadQuestionsByQuizId(quizId);
      if (isClosed) return false;
      emit(state.copyWith(status: QuestionStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: 'Tạo câu hỏi bằng tay thất bại',
        ),
      );
    }
    return result;
  }

  /// Tạo câu hỏi bằng AI
  Future<bool> createQuestionAI(Map<String, dynamic> data, int quizId) async {
    emit(state.copyWith(status: QuestionStatus.loading));
    final result = await _repository.createQuestionAI(data);
    if (result) {
      await loadQuestionsByQuizId(quizId);
      if (isClosed) return false;
      emit(state.copyWith(status: QuestionStatus.loaded));
    } else {
      emit(
        state.copyWith(
          status: QuestionStatus.error,
          errorMessage: 'Tạo câu hỏi bằng AI thất bại',
        ),
      );
    }
    return result;
  }
}
