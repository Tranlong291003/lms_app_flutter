import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/repositories/lesson_repository.dart';

/// Cubit quản lý trạng thái và xử lý các thao tác với danh sách bài học
class LessonsCubit extends Cubit<LessonsState> {
  final LessonRepository _repository;

  LessonsCubit({LessonRepository? repository})
    : _repository = repository ?? LessonRepository(),
      super(const LessonsInitial());

  /// Tải danh sách bài học của khóa học
  ///
  /// [courseId] - ID của khóa học
  /// [userUid] - ID của người dùng
  Future<void> loadLessons({
    required int courseId,
    required String userUid,
  }) async {
    emit(const LessonsLoading());
    try {
      final lessons = await _repository.getAllLessons(courseId, userUid);
      emit(LessonsLoaded(lessons: lessons));
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }

  /// Tải chi tiết một bài học
  ///
  /// [lessonId] - ID của bài học cần tải
  Future<Lesson> loadLessonDetail(int lessonId) async {
    try {
      emit(const LessonsLoading());
      final lesson = await _repository.getLessonDetail(lessonId);

      // Cập nhật state
      if (state is LessonsLoaded) {
        final currentState = state as LessonsLoaded;
        emit(currentState.copyWith(currentLesson: lesson));
      } else {
        emit(LessonsLoaded(lessons: const [], currentLesson: lesson));
      }

      // Trả về lesson cho caller
      return lesson;
    } catch (e) {
      print('[LessonsCubit] Lỗi khi tải chi tiết bài học: $e');
      emit(LessonsError(e.toString()));
      rethrow; // Throw lại lỗi để caller xử lý
    }
  }

  Future<void> createLesson({
    required int courseId,
    required String title,
    required String videoUrl,
    required String content,
    required int order,
    required String uid,
    File? pdf,
    File? slide,
  }) async {
    emit(LessonsLoading());
    try {
      await _repository.createLesson(
        courseId: courseId,
        title: title,
        videoUrl: videoUrl,
        content: content,
        order: order,
        uid: uid,
        pdf: pdf,
        slide: slide,
      );
      await loadLessons(courseId: courseId, userUid: uid);
    } catch (e) {
      emit(LessonsError(e.toString()));
    }
  }

  /// Cập nhật bài học
  Future<void> updateLesson({
    required int lessonId,
    required int courseId,
    required String title,
    required String videoUrl,
    required String content,
    required int order,
    required String uid,
    File? pdf,
    File? slide,
  }) async {
    try {
      emit(LessonsLoading());

      final data = {
        'title': title,
        'video_url': videoUrl,
        'content': content,
        'order': order,
        'uid': uid,
        'course_id': courseId,
      };

      await _repository.updateLesson(
        lessonId: lessonId,
        data: data,
        pdf: pdf,
        slide: slide,
      );

      await loadLessons(courseId: courseId, userUid: uid);
    } catch (e) {
      print('[LessonsCubit] ❌ Lỗi cập nhật bài học: $e');
      emit(LessonsError(e.toString()));
      rethrow;
    }
  }

  /// Xoá bài học
  Future<void> deleteLesson({
    required int lessonId,
    required int courseId,
    required String userUid,
  }) async {
    try {
      // Emit loading state
      emit(LessonsLoading());

      // Gọi API xóa bài học
      await _repository.deleteLesson(lessonId: lessonId, uid: userUid);

      // Reload danh sách bài học sau khi xoá
      await loadLessons(courseId: courseId, userUid: userUid);
    } catch (e) {
      print('[LessonsCubit] ❌ Lỗi xoá bài học: $e');
      emit(LessonsError(e.toString()));
      rethrow;
    }
  }
}
