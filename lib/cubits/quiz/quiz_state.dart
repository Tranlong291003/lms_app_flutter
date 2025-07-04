import 'package:lms/models/quiz/quiz_course_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';

enum QuizStatus { initial, loading, loaded, error }

class QuizState {
  final QuizStatus status;
  final List<QuizCourseModel> enrolledCourses;
  final List<QuizCourseModel> notEnrolledCourses;
  final String errorMessage;
  final bool isLoading;
  final List<QuizModel> quizzesByCourseId;

  QuizState({
    this.status = QuizStatus.initial,
    this.enrolledCourses = const [],
    this.notEnrolledCourses = const [],
    this.errorMessage = '',
    this.isLoading = false,
    this.quizzesByCourseId = const [],
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuizCourseModel>? enrolledCourses,
    List<QuizCourseModel>? notEnrolledCourses,
    String? errorMessage,
    bool? isLoading,
    List<QuizModel>? quizzesByCourseId,
  }) {
    return QuizState(
      status: status ?? this.status,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      notEnrolledCourses: notEnrolledCourses ?? this.notEnrolledCourses,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      quizzesByCourseId: quizzesByCourseId ?? this.quizzesByCourseId,
    );
  }
}
