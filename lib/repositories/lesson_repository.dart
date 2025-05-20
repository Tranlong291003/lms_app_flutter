import 'dart:io';

import 'package:lms/models/lesson_model.dart';
import 'package:lms/services/lesson_service.dart';

class LessonRepository {
  final LessonService _lessonService;

  LessonRepository({LessonService? lessonService})
    : _lessonService = lessonService ?? LessonService();

  Future<List<Lesson>> getAllLessons(int courseId, String userUid) =>
      _lessonService.getAllLessons(courseId, userUid);

  Future<Lesson> getLessonDetail(int lessonId) =>
      _lessonService.getLessonDetail(lessonId);

  Future<void> completeLesson(
    int lessonId,
    String userUid,
    int courseId,
  ) async {
    try {
      print(
        '[LessonRepository] ▶️ Bắt đầu gọi service để đánh dấu bài học hoàn thành',
      );
      print('[LessonRepository] 📝 LessonId: $lessonId');
      print('[LessonRepository] 📝 UserUid: $userUid');
      print('[LessonRepository] 📝 CourseId: $courseId');

      await _lessonService.completeLesson(lessonId, userUid, courseId);

      print('[LessonRepository] ✅ Đã đánh dấu bài học hoàn thành thành công');
    } catch (e) {
      print('[LessonRepository] ❌ Lỗi khi đánh dấu bài học hoàn thành: $e');
      throw Exception('Không thể đánh dấu bài học đã hoàn thành: $e');
    }
  }

  /// Tạo mới bài học
  Future<void> createLesson({
    required int courseId,
    required String title,
    required String videoUrl,
    required String content,
    required int order,
    required String uid,
    File? pdf,
    File? slide,
  }) => _lessonService.createLesson(
    courseId: courseId,
    title: title,
    videoUrl: videoUrl,
    content: content,
    order: order,
    uid: uid,
    pdf: pdf,
    slide: slide,
  );

  /// Cập nhật bài học
  Future<void> updateLesson({
    required int lessonId,
    required Map<String, dynamic> data,
    File? pdf,
    File? slide,
  }) => _lessonService.updateLesson(
    lessonId: lessonId,
    data: data,
    pdf: pdf,
    slide: slide,
  );

  /// Xoá bài học
  Future<void> deleteLesson({required int lessonId, required String uid}) =>
      _lessonService.deleteLesson(lessonId: lessonId, uid: uid);
}
