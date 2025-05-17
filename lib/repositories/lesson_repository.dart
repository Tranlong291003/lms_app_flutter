import 'package:dio/dio.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/services/lesson_service.dart';

class LessonRepository {
  final LessonService _lessonService;

  LessonRepository({LessonService? lessonService})
    : _lessonService = lessonService ?? LessonService();

  Future<Response> getAllLessons({
    required int courseId,
    required String userUid,
  }) async {
    try {
      return await _lessonService.getAllLessons(
        courseId: courseId,
        userUid: userUid,
      );
    } catch (e) {
      throw Exception('Không thể lấy danh sách bài học: $e');
    }
  }

  Future<Lesson> getLessonDetail(int lessonId) async {
    try {
      return await _lessonService.getLessonDetail(lessonId);
    } catch (e) {
      throw Exception('Không thể lấy thông tin bài học: $e');
    }
  }

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
}
