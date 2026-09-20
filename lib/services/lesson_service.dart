import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/lesson_model.dart';

import 'base_service.dart';

class LessonService extends BaseService {
  LessonService({super.token});

  Future<List<Lesson>> getAllLessons(int courseId, String userUid) async {
    try {
      final response = await get(
        ApiConfig.getLessonsByCourseAndUser(courseId, userUid),
      );
      if (response.statusCode == 200 && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((json) => Lesson.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      throw Exception('Không thể lấy danh sách bài học');
    } on DioException catch (e) {
      throw Exception(
        'Không thể lấy danh sách bài học: ${extractApiError(e)}',
      );
    }
  }

  /// Lấy chi tiết bài học
  Future<Lesson> getLessonDetail(int lessonId) async {
    try {
      final response = await get(ApiConfig.getLessonDetail(lessonId));
      if (response.statusCode == 200 && response.data['data'] is Map) {
        return Lesson.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception('Không thể lấy chi tiết bài học');
    } on DioException catch (e) {
      throw Exception(
        'Không thể lấy chi tiết bài học: ${extractApiError(e)}',
      );
    }
  }

  /// Đánh dấu bài học đã hoàn thành.
  ///
  /// `POST /api/lessons/complete` nhận `{ courseId, lessonId }` và lấy uid từ
  /// token; uid truyền kèm chỉ để tương thích và phải trùng với token.
  /// Trả về `200 { status: "insert"|"update", message }`.
  Future<void> completeLesson(
    int lessonId,
    String userUid,
    int courseId,
  ) async {
    try {
      final response = await post(
        ApiConfig.completeLesson,
        data: {'courseId': courseId, 'lessonId': lessonId, 'userUid': userUid},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data is Map
              ? (response.data['error'] ?? response.data['message'])
              : 'Đánh dấu bài học không thành công',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Bạn chưa đăng ký khóa học này');
      }
      throw Exception(
        'Không thể đánh dấu bài học đã hoàn thành: ${extractApiError(e)}',
      );
    }
  }

  /// Cập nhật bài học
  Future<void> updateLesson({
    required int lessonId,
    required Map<String, dynamic> data,
    File? pdf,
    File? slide,
  }) async {
    try {
      final fields = <String, dynamic>{...data};
      if (pdf != null) {
        fields['pdf'] = await MultipartFile.fromFile(
          pdf.path,
          filename: pdf.path.split(Platform.pathSeparator).last,
        );
      }
      if (slide != null) {
        fields['slide'] = await MultipartFile.fromFile(
          slide.path,
          filename: slide.path.split(Platform.pathSeparator).last,
        );
      }

      final response = await put(
        ApiConfig.updateLesson(lessonId),
        data: FormData.fromMap(fields),
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data is Map
              ? (response.data['error'] ?? response.data['message'])
              : 'Cập nhật bài học thất bại',
        );
      }
    } catch (e) {
      throw Exception(
        'Cập nhật bài học thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// Xoá bài học
  Future<void> deleteLesson({
    required int lessonId,
    required String uid,
  }) async {
    try {
      final response = await delete(
        ApiConfig.deleteLesson(lessonId),
        data: {'uid': uid},
      );
      if (response.statusCode != 200) {
        throw Exception('Xóa bài học thất bại');
      }
    } on DioException catch (e) {
      throw Exception('Xóa bài học thất bại: ${extractApiError(e)}');
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
    try {
      final fields = <String, dynamic>{
        'course_id': courseId,
        'title': title,
        'video_url': videoUrl,
        'content': content,
        'order': order,
        'uid': uid,
        if (pdf != null)
          'pdf': await MultipartFile.fromFile(
            pdf.path,
            filename: pdf.path.split(Platform.pathSeparator).last,
          ),
        if (slide != null)
          'slide': await MultipartFile.fromFile(
            slide.path,
            filename: slide.path.split(Platform.pathSeparator).last,
          ),
      };

      final response = await post(
        ApiConfig.createLesson,
        data: FormData.fromMap(fields),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data is Map
              ? (response.data['error'] ?? response.data['message'])
              : 'Tạo bài học thất bại',
        );
      }
    } catch (e) {
      throw Exception(
        'Tạo bài học thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }
}
