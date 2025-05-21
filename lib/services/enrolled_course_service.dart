import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/enrolledCourse_model.dart';
import 'package:lms/services/base_service.dart';

class EnrolledCourseService extends BaseService {
  EnrolledCourseService({super.token});

  /// Lấy danh sách khóa học đã đăng ký của người dùng
  Future<Map<String, List<EnrolledCourse>>> getEnrolledCourses(
    String userUid,
  ) async {
    try {
      final response = await get(ApiConfig.getEnrolledCoursesByUser(userUid));

      // Khởi tạo kết quả mặc định
      final result = {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          final data = responseData['data'] as Map<String, dynamic>;

          // Xử lý khóa học đang học (in_progress)
          if (data.containsKey('in_progress') && data['in_progress'] is List) {
            result['in_progress'] =
                (data['in_progress'] as List)
                    .map((item) => EnrolledCourse.fromJson(item))
                    .toList();
          }

          // Xử lý khóa học đã hoàn thành (completed)
          if (data.containsKey('completed') && data['completed'] is List) {
            result['completed'] =
                (data['completed'] as List)
                    .map((item) => EnrolledCourse.fromJson(item))
                    .toList();
          }
        }
      }

      print('[EnrolledCourseService] Đã xử lý dữ liệu đăng ký thành công');
      return result; // Trả về kết quả (có thể rỗng nếu lỗi hoặc không có dữ liệu)
    } on DioException catch (e) {
      print('[EnrolledCourseService] Lỗi DioException: ${e.message}');
      print('[EnrolledCourseService] Response: ${e.response?.data}');
      // Trả về danh sách rỗng trong trường hợp lỗi
      return {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };
    } catch (e) {
      print('[EnrolledCourseService] Lỗi không xác định: $e');
      // Trả về danh sách rỗng trong trường hợp lỗi
      return {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };
    }
  }

  /// In ra cấu trúc của response để debug
  void _debugPrintResponse(dynamic data) {
    try {
      if (data == null) {
        print('[EnrolledCourseService] Response data là null');
        return;
      }

      print('[EnrolledCourseService] Kiểu dữ liệu: ${data.runtimeType}');

      if (data is Map) {
        print(
          '[EnrolledCourseService] Response là Map với các key: ${data.keys.toList()}',
        );

        // Kiểm tra xem có trường data không
        if (data.containsKey('data')) {
          final innerData = data['data'];
          print(
            '[EnrolledCourseService] Kiểu dữ liệu của trường data: ${innerData.runtimeType}',
          );

          if (innerData is Map) {
            print(
              '[EnrolledCourseService] Trường data là Map với các key: ${innerData.keys.toList()}',
            );
          } else if (innerData is List) {
            print(
              '[EnrolledCourseService] Trường data là List với ${innerData.length} phần tử',
            );
            if (innerData.isNotEmpty) {
              print(
                '[EnrolledCourseService] Kiểu dữ liệu phần tử đầu tiên: ${innerData.first.runtimeType}',
              );
            }
          }
        }
      } else if (data is List) {
        print(
          '[EnrolledCourseService] Response là List với ${data.length} phần tử',
        );
        if (data.isNotEmpty) {
          print(
            '[EnrolledCourseService] Kiểu dữ liệu phần tử đầu tiên: ${data.first.runtimeType}',
          );
        }
      }

      // In ra JSON string để xem cấu trúc đầy đủ (giới hạn độ dài)
      final jsonString = jsonEncode(data);
      if (jsonString.length > 500) {
        print(
          '[EnrolledCourseService] JSON: ${jsonString.substring(0, 500)}...',
        );
      } else {
        print('[EnrolledCourseService] JSON: $jsonString');
      }
    } catch (e) {
      print('[EnrolledCourseService] Lỗi khi in debug: $e');
    }
  }
}
