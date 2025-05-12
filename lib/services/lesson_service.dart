import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/lesson_model.dart';

import 'base_service.dart';

class LessonService extends BaseService {
  LessonService({super.token});

  /// Lấy danh sách tất cả bài học của khóa học
  Future<Response> getAllLessons({
    required int courseId,
    required String userUid,
  }) async {
    try {
      final url = ApiConfig.getLessonsByCourseAndUser(courseId, userUid);
      print('[LessonService] ▶️ GET $url');
      final response = await get(url);
      print(
        '[LessonService] ✅ ${response.statusCode} - data: ${response.data}',
      );
      return response;
    } on DioException catch (e) {
      print(
        '[LessonService] ❌ DIO ERROR status=${e.response?.statusCode} - message=${e.message}',
      );
      rethrow;
    } catch (e) {
      print('[LessonService] ❌ UNEXPECTED ERROR - $e');
      rethrow;
    }
  }

  /// Lấy chi tiết bài học
  Future<Lesson> getLessonDetail(int lessonId) async {
    try {
      final url = ApiConfig.getLessonDetail(lessonId);
      print('[LessonService] ▶️ GET $url');
      final response = await get(url);
      print(
        '[LessonService] ✅ ${response.statusCode} - data: ${response.data}',
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data['data'];
          if (data == null) {
            throw Exception('Không tìm thấy dữ liệu bài học');
          }
          return Lesson.fromJson(data);
        } catch (e) {
          print('[LessonService] ❌ PARSE ERROR - $e');
          throw Exception('Dữ liệu bài học không hợp lệ: $e');
        }
      } else {
        throw Exception('Không thể tải thông tin bài học');
      }
    } on DioException catch (e) {
      print(
        '[LessonService] ❌ DIO ERROR status=${e.response?.statusCode} - message=${e.message}',
      );
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      print('[LessonService] ❌ UNEXPECTED ERROR - $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> completeLesson(
    int lessonId,
    String userUid,
    int courseId,
  ) async {
    try {
      // URL không có tham số
      final url = ApiConfig.completeLesson;
      print('========== COMPLETE LESSON REQUEST ==========');
      print('[LessonService] ▶️ Bắt đầu đánh dấu bài học hoàn thành');
      print('[LessonService] 📝 URL: $url');
      print('[LessonService] 📝 Method: POST');
      print(
        '[LessonService] 📝 Body: { "lessonId": $lessonId, "userUid": "$userUid", "courseId": $courseId }',
      );
      print('============================================');

      // Truyền tất cả tham số trong body
      final response = await post(
        url,
        data: {'lessonId': lessonId, 'userUid': userUid, 'courseId': courseId},
        options: Options(contentType: Headers.jsonContentType),
      );

      print('========== COMPLETE LESSON RESPONSE ==========');
      print('[LessonService] ✅ Response status: ${response.statusCode}');
      print('[LessonService] ✅ Response data: ${response.data}');
      print('=============================================');

      if (response.statusCode == 200) {
        print('[LessonService] 🎉 Đánh dấu bài học hoàn thành thành công');
      } else {
        print(
          '[LessonService] ⚠️ Response không thành công: ${response.statusCode}',
        );
        throw Exception(
          'Đánh dấu bài học không thành công: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('========== COMPLETE LESSON ERROR ==========');
      print('[LessonService] ❌ DIO ERROR:');
      print('[LessonService] ❌ Status: ${e.response?.statusCode}');
      print('[LessonService] ❌ Message: ${e.message}');
      print('[LessonService] ❌ Data: ${e.response?.data}');
      print('[LessonService] ❌ Request: ${e.requestOptions.uri}');
      print('[LessonService] ❌ Headers: ${e.requestOptions.headers}');
      print('==========================================');
      throw Exception('Lỗi kết nối: ${e.message}');
    } catch (e) {
      print('========== COMPLETE LESSON ERROR ==========');
      print('[LessonService] ❌ UNEXPECTED ERROR:');
      print('[LessonService] ❌ Error: $e');
      print('==========================================');
      throw Exception('Không thể đánh dấu bài học đã hoàn thành: $e');
    }
  }
}
