// lib/blocs/cubit/courses/course_state.dart
part of 'course_cubit.dart';

abstract class CourseState extends Equatable {
  const CourseState();
  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {
  const CourseInitial();
}

class CourseLoading extends CourseState {
  const CourseLoading();
}

class CourseLoaded extends CourseState {
  final List<Course> courses;
  final List<Course> randomCourses;
  const CourseLoaded(this.courses, this.randomCourses);
  @override
  List<Object?> get props => [courses, randomCourses];
}

class CourseError extends CourseState {
  final String message;
  const CourseError(this.message);
  @override
  List<Object?> get props => [message];
}
