import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/lesson_model.dart';

import 'base_service.dart';

class LessonService extends BaseService {
  LessonService({super.token});

  Future<List<Lesson>> getAllLessons(int courseId, String userUid) async {
    final response = await get(
      ApiConfig.getLessonsByCourseAndUser(courseId, userUid),
    );
    if (response.statusCode == 200 && response.data['data'] is List) {
      return (response.data['data'] as List)
          .map((json) => Lesson.fromJson(json))
          .toList();
    }
    throw Exception('Không thể lấy danh sách bài học');
  }

  /// Lấy chi tiết bài học
  Future<Lesson> getLessonDetail(int lessonId) async {
    final response = await get(ApiConfig.getLessonDetail(lessonId));
    if (response.statusCode == 200 && response.data['data'] != null) {
      return Lesson.fromJson(response.data['data']);
    }
    throw Exception('Không thể lấy chi tiết bài học');
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

  /// Cập nhật bài học
  Future<void> updateLesson({
    required int lessonId,
    required Map<String, dynamic> data,
    File? pdf,
    File? slide,
  }) async {
    Response response;
    if (pdf != null || slide != null) {
      final formData = FormData.fromMap({
        ...data,
        if (pdf != null)
          'pdf': await MultipartFile.fromFile(
            pdf.path,
            filename: pdf.path.split('/').last,
          ),
        if (slide != null)
          'slide': await MultipartFile.fromFile(
            slide.path,
            filename: slide.path.split('/').last,
          ),
      });
      response = await put(
        ApiConfig.updateLesson(lessonId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      response = await put(ApiConfig.updateLesson(lessonId), data: data);
    }
    if (response.statusCode != 200) {
      throw Exception('Cập nhật bài học thất bại');
    }
  }

  /// Xoá bài học
  Future<void> deleteLesson({
    required int lessonId,
    required String uid,
  }) async {
    final response = await delete(
      ApiConfig.deleteLesson(lessonId),
      data: {'uid': uid},
    );
    if (response.statusCode != 200) {
      throw Exception('Xóa bài học thất bại');
    }
  }

  /// Gọi API tạo mới bài học
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
    final formData = FormData.fromMap({
      'course_id': courseId,
      'title': title,
      'video_url': videoUrl,
      'content': content,
      'order': order,
      'uid': uid,
      if (pdf != null)
        'pdf': await MultipartFile.fromFile(
          pdf.path,
          filename: pdf.path.split('/').last,
        ),
      if (slide != null)
        'slide': await MultipartFile.fromFile(
          slide.path,
          filename: slide.path.split('/').last,
        ),
    });
    final response = await post(
      ApiConfig.createLesson,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Tạo bài học thất bại');
    }
  }
}
