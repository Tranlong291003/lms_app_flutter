// lib/cubit/enrolled_courses/enrolled_course_state.dart
import 'package:equatable/equatable.dart';
import 'package:lms/models/enrolledCourse_model.dart';

abstract class EnrolledCourseState extends Equatable {
  const EnrolledCourseState();

  @override
  List<Object?> get props => [];
}

class EnrolledCourseInitial extends EnrolledCourseState {
  const EnrolledCourseInitial();
}

class EnrolledCourseLoading extends EnrolledCourseState {
  const EnrolledCourseLoading();
}

class EnrolledCourseLoaded extends EnrolledCourseState {
  final List<EnrolledCourse> allCourses;
  final List<EnrolledCourse> ongoingCourses;
  final List<EnrolledCourse> completedCourses;

  const EnrolledCourseLoaded({
    required this.allCourses,
    required this.ongoingCourses,
    required this.completedCourses,
  });

  @override
  List<Object?> get props => [allCourses, ongoingCourses, completedCourses];
}

class EnrolledCourseError extends EnrolledCourseState {
  final String message;

  const EnrolledCourseError(this.message);

  @override
  List<Object?> get props => [message];
}
