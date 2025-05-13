part of 'course_cubit.dart';

@immutable
abstract class CourseDetailState {}

class CourseDetailInitial extends CourseDetailState {}

class CourseDetailLoading extends CourseDetailState {}

class CourseDetailLoaded extends CourseDetailState {
  final CourseDetail detail;
  CourseDetailLoaded(this.detail);
}

class CourseDetailError extends CourseDetailState {
  final String message;
  CourseDetailError(this.message);
}
