import 'package:equatable/equatable.dart';
import 'package:lms/models/lesson_model.dart';

abstract class LessonDetailState extends Equatable {
  const LessonDetailState();

  @override
  List<Object?> get props => [];
}

class LessonDetailInitial extends LessonDetailState {}

class LessonDetailLoading extends LessonDetailState {}

class LessonDetailLoaded extends LessonDetailState {
  final Lesson lesson;
  final bool isCompleted;

  const LessonDetailLoaded({required this.lesson, this.isCompleted = false});

  @override
  List<Object?> get props => [lesson, isCompleted];

  LessonDetailLoaded copyWith({Lesson? lesson, bool? isCompleted}) {
    return LessonDetailLoaded(
      lesson: lesson ?? this.lesson,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class LessonDetailError extends LessonDetailState {
  final String message;

  const LessonDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
