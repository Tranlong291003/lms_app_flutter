import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/repositories/lesson_repository.dart';

// State
abstract class LessonsState {}

class LessonsInitial extends LessonsState {}

class LessonsLoading extends LessonsState {}

class LessonsLoaded extends LessonsState {
  final List<Lesson> lessons;
  final Lesson? currentLesson;

  LessonsLoaded({required this.lessons, this.currentLesson});

  LessonsLoaded copyWith({List<Lesson>? lessons, Lesson? currentLesson}) {
    return LessonsLoaded(
      lessons: lessons ?? this.lessons,
      currentLesson: currentLesson ?? this.currentLesson,
    );
  }
}

class LessonsError extends LessonsState {
  final String message;

  LessonsError(this.message);
}

// Cubit
class LessonsCubit extends Cubit<LessonsState> {
  final LessonRepository _repository;

  LessonsCubit({LessonRepository? repository})
    : _repository = repository ?? LessonRepository(),
      super(LessonsInitial());

  Future<void> loadLessons({
    required int courseId,
    required String userUid,
  }) async {
    try {
      emit(LessonsLoading());
      final response = await _repository.getAllLessons(
        courseId: courseId,
        userUid: userUid,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      final lessons = data.map((json) => Lesson.fromJson(json)).toList();
      emit(LessonsLoaded(lessons: lessons));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }

  Future<void> loadLessonDetail(int lessonId) async {
    try {
      if (state is LessonsLoaded) {
        final currentState = state as LessonsLoaded;
        emit(LessonsLoading());
        final lesson = await _repository.getLessonDetail(lessonId);
        emit(currentState.copyWith(currentLesson: lesson));
      } else {
        emit(LessonsLoading());
        final lesson = await _repository.getLessonDetail(lessonId);
        emit(LessonsLoaded(lessons: const [], currentLesson: lesson));
      }
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }
}
