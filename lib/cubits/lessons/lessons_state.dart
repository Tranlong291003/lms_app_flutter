import 'package:equatable/equatable.dart';
import 'package:lms/models/lesson_model.dart';

/// Trạng thái của lessons cubit
abstract class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => [];
}

/// Trạng thái khởi tạo
class LessonsInitial extends LessonsState {
  const LessonsInitial();
}

/// Trạng thái đang tải
class LessonsLoading extends LessonsState {
  const LessonsLoading();
}

/// Trạng thái đã tải xong
class LessonsLoaded extends LessonsState {
  final List<Lesson> lessons;
  final Lesson? currentLesson;

  const LessonsLoaded({required this.lessons, this.currentLesson});

  LessonsLoaded copyWith({List<Lesson>? lessons, Lesson? currentLesson}) {
    return LessonsLoaded(
      lessons: lessons ?? this.lessons,
      currentLesson: currentLesson ?? this.currentLesson,
    );
  }

  @override
  List<Object?> get props => [lessons, currentLesson];
}

/// Trạng thái lỗi
class LessonsError extends LessonsState {
  final String message;

  const LessonsError(this.message);

  @override
  List<Object?> get props => [message];
}
