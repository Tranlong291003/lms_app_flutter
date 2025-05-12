import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/repository/lesson_repository.dart';

// State
class LessonsState {
  final List<Lesson> lessons;
  final bool isLoading;
  final String? error;

  LessonsState({this.lessons = const [], this.isLoading = false, this.error});

  LessonsState copyWith({
    List<Lesson>? lessons,
    bool? isLoading,
    String? error,
  }) {
    return LessonsState(
      lessons: lessons ?? this.lessons,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Cubit
class LessonsCubit extends Cubit<LessonsState> {
  final LessonRepository _repository;

  LessonsCubit({LessonRepository? repository})
    : _repository = repository ?? LessonRepository(),
      super(LessonsState());

  Future<void> loadLessons({
    required int courseId,
    required String userUid,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));
      final response = await _repository.getAllLessons(
        courseId: courseId,
        userUid: userUid,
      );
      final List<dynamic> data = response.data ?? [];
      final lessons = data.map((json) => Lesson.fromJson(json)).toList();
      emit(state.copyWith(lessons: lessons, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
