import 'package:lms/models/quiz/quiz_course_model.dart';

enum QuizStatus { initial, loading, loaded, error }

class QuizState {
  final QuizStatus status;
  final List<QuizCourseModel> enrolledCourses;
  final List<QuizCourseModel> notEnrolledCourses;
  final String errorMessage;
  final bool isLoading;

  QuizState({
    this.status = QuizStatus.initial,
    this.enrolledCourses = const [],
    this.notEnrolledCourses = const [],
    this.errorMessage = '',
    this.isLoading = false,
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuizCourseModel>? enrolledCourses,
    List<QuizCourseModel>? notEnrolledCourses,
    String? errorMessage,
    bool? isLoading,
  }) {
    return QuizState(
      status: status ?? this.status,
      enrolledCourses: enrolledCourses ?? this.enrolledCourses,
      notEnrolledCourses: notEnrolledCourses ?? this.notEnrolledCourses,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
