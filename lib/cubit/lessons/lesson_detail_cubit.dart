import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubit/lessons/lesson_detail_state.dart';
import 'package:lms/repository/lesson_repository.dart';

class LessonDetailCubit extends Cubit<LessonDetailState> {
  final LessonRepository _lessonRepository;

  LessonDetailCubit({LessonRepository? lessonRepository})
    : _lessonRepository = lessonRepository ?? LessonRepository(),
      super(LessonDetailInitial());

  Future<void> loadLessonDetail(int lessonId) async {
    try {
      print('[LessonDetailCubit] ▶️ Bắt đầu tải chi tiết bài học');
      print('[LessonDetailCubit] 📝 LessonId: $lessonId');

      emit(LessonDetailLoading());
      final lesson = await _lessonRepository.getLessonDetail(lessonId);

      print('[LessonDetailCubit] ✅ Đã tải chi tiết bài học thành công');
      print('[LessonDetailCubit] 📝 Lesson title: ${lesson.title}');

      emit(LessonDetailLoaded(lesson: lesson));
    } catch (e) {
      print('[LessonDetailCubit] ❌ Lỗi khi tải chi tiết bài học: $e');
      emit(LessonDetailError(e.toString()));
    }
  }

  Future<void> completeLesson(
    int lessonId,
    String userUid,
    int courseId,
  ) async {
    try {
      print('[LessonDetailCubit] ▶️ Bắt đầu xử lý đánh dấu bài học hoàn thành');
      print('[LessonDetailCubit] 📝 LessonId: $lessonId');
      print('[LessonDetailCubit] 📝 UserUid: $userUid');
      print('[LessonDetailCubit] 📝 CourseId: $courseId');

      if (state is LessonDetailLoaded) {
        final currentState = state as LessonDetailLoaded;
        print(
          '[LessonDetailCubit] 📝 Current lesson: ${currentState.lesson.title}',
        );

        await _lessonRepository.completeLesson(lessonId, userUid, courseId);
        print('[LessonDetailCubit] ✅ Đã gọi repository đánh dấu hoàn thành');

        emit(currentState.copyWith(isCompleted: true));
        print('[LessonDetailCubit] ✅ Đã cập nhật state thành hoàn thành');
      } else {
        print('[LessonDetailCubit] ⚠️ State không phải LessonDetailLoaded');
        throw Exception('Không thể đánh dấu bài học: State không hợp lệ');
      }
    } catch (e) {
      print('[LessonDetailCubit] ❌ Lỗi khi đánh dấu bài học: $e');
      emit(LessonDetailError(e.toString()));
    }
  }
}
