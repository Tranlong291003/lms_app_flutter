import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/quiz/quiz_state.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/repository/question_repository.dart';
import 'package:lms/repository/quiz_repository.dart';

part 'quiz_result_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepository _quizRepository;

  QuizCubit(this._quizRepository) : super(QuizState());

  Future<void> getQuizzesByUser(String userUid) async {
    try {
      emit(state.copyWith(status: QuizStatus.loading, isLoading: true));

      print('QuizCubit: Đang lấy danh sách bài kiểm tra cho user: $userUid');
      final result = await _quizRepository.getQuizzesByUser(userUid);

      final enrolledCourses = result['enrolledCourses'] ?? [];
      final notEnrolledCourses = result['notEnrolledCourses'] ?? [];

      print(
        'QuizCubit: Đã nhận được ${enrolledCourses.length} khóa học đã đăng ký',
      );
      print(
        'QuizCubit: Đã nhận được ${notEnrolledCourses.length} khóa học chưa đăng ký',
      );

      emit(
        state.copyWith(
          status: QuizStatus.loaded,
          enrolledCourses: enrolledCourses,
          notEnrolledCourses: notEnrolledCourses,
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Lỗi Cubit khi lấy danh sách bài kiểm tra: $e');
      emit(
        state.copyWith(
          status: QuizStatus.error,
          errorMessage: 'Không thể lấy danh sách bài kiểm tra: $e',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> refreshQuizzes(String userUid) async {
    try {
      print(
        'QuizCubit: Đang làm mới danh sách bài kiểm tra cho user: $userUid',
      );
      emit(state.copyWith(isLoading: true));

      final result = await _quizRepository.getQuizzesByUser(userUid);

      final enrolledCourses = result['enrolledCourses'] ?? [];
      final notEnrolledCourses = result['notEnrolledCourses'] ?? [];

      print(
        'QuizCubit: Đã làm mới - ${enrolledCourses.length} khóa học đã đăng ký',
      );
      print(
        'QuizCubit: Đã làm mới - ${notEnrolledCourses.length} khóa học chưa đăng ký',
      );

      emit(
        state.copyWith(
          enrolledCourses: enrolledCourses,
          notEnrolledCourses: notEnrolledCourses,
          isLoading: false,
        ),
      );
    } catch (e) {
      print('Lỗi QuizCubit khi làm mới danh sách bài kiểm tra: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  int getTotalEnrolledQuizzes() {
    int total = 0;
    for (var course in state.enrolledCourses) {
      total += course.quizzes.length;
    }
    return total;
  }

  int getTotalNotEnrolledQuizzes() {
    int total = 0;
    for (var course in state.notEnrolledCourses) {
      total += course.quizzes.length;
    }
    return total;
  }
}

class QuizResultCubit extends Cubit<QuizResultState> {
  final QuestionRepository repository;
  QuizResultCubit(this.repository) : super(QuizResultInitial());

  Future<void> fetchQuizResult(int resultId) async {
    emit(QuizResultLoading());
    try {
      final result = await repository.getQuizResultDetails(resultId);
      if (result['success'] == true && result['data'] != null) {
        final model = QuizResultModel.fromJson(result['data']);
        emit(QuizResultLoaded(model));
      } else {
        emit(QuizResultError(result['message'] ?? 'Lỗi không xác định'));
      }
    } catch (e) {
      emit(QuizResultError(e.toString()));
    }
  }
}

class QuizResultListState {}

class QuizResultListInitial extends QuizResultListState {}

class QuizResultListLoading extends QuizResultListState {}

class QuizResultListLoaded extends QuizResultListState {
  final List<QuizResultModel> results;
  QuizResultListLoaded(this.results);
}

class QuizResultListError extends QuizResultListState {
  final String message;
  QuizResultListError(this.message);
}

class QuizResultListCubit extends Cubit<QuizResultListState> {
  final QuizRepository repository;
  QuizResultListCubit(this.repository) : super(QuizResultListInitial());

  Future<void> fetchUserQuizResults(String userUid) async {
    print(
      'QuizResultListCubit: Bắt đầu fetch kết quả đã làm cho user $userUid',
    );
    emit(QuizResultListLoading());
    try {
      final results = await repository.getUserQuizResults(userUid);
      print('QuizResultListCubit: Đã fetch xong, có ${results.length} kết quả');
      emit(QuizResultListLoaded(results));
    } catch (e) {
      print('QuizResultListCubit: Lỗi khi fetch kết quả: $e');
      emit(QuizResultListError(e.toString()));
    }
  }
}
