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
      // print(
      //   '[EnrolledCourseService] Đang gọi API: ${ApiConfig.getEnrolledCoursesByUser(userUid)}',
      // );
      final response = await get(ApiConfig.getEnrolledCoursesByUser(userUid));

      // print('[EnrolledCourseService] Kết quả trả về: ${response.statusCode}');
      // _debugPrintResponse(response.data);

      // Khởi tạo kết quả mặc định
      final result = {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };

      if (response.statusCode == 200) {
        // Kiểm tra xem response.data có phải là Map hay không
        if (response.data is Map<String, dynamic>) {
          // print('[EnrolledCourseService] Dữ liệu trả về là Map');

          // Kiểm tra xem có trường 'data' trong Map không
          if (response.data.containsKey('data')) {
            final data = response.data['data'];

            // Kiểm tra xem trường 'data' có phải là Map không
            if (data is Map<String, dynamic>) {
              print(
                '[EnrolledCourseService] Trường data là Map với các key: ${data.keys.toList()}',
              );

              // Xử lý khóa học đang học (in_progress)
              if (data.containsKey('in_progress') &&
                  data['in_progress'] is List) {
                final inProgressList = data['in_progress'] as List;
                print(
                  '[EnrolledCourseService] Có ${inProgressList.length} khóa học đang học',
                );

                result['in_progress'] =
                    inProgressList
                        .map((item) => EnrolledCourse.fromJson(item))
                        .toList();
              }

              // Xử lý khóa học đã hoàn thành (completed)
              if (data.containsKey('completed') && data['completed'] is List) {
                final completedList = data['completed'] as List;
                print(
                  '[EnrolledCourseService] Có ${completedList.length} khóa học đã hoàn thành',
                );

                result['completed'] =
                    completedList
                        .map((item) => EnrolledCourse.fromJson(item))
                        .toList();
              }

              return result;
            } else {
              print(
                '[EnrolledCourseService] Trường data không phải là Map: ${data.runtimeType}',
              );
            }
          } else {
            print(
              '[EnrolledCourseService] Không tìm thấy trường data trong response',
            );
          }
        } else {
          print(
            '[EnrolledCourseService] Dữ liệu trả về không phải là Map: ${response.data.runtimeType}',
          );
        }
      } else {
        print(
          '[EnrolledCourseService] Mã trạng thái không phải 200: ${response.statusCode}',
        );
      }

      return result; // Trả về kết quả mặc định nếu có lỗi
    } on DioException catch (e) {
      print('[EnrolledCourseService] Lỗi DioException: ${e.message}');
      print('[EnrolledCourseService] Response: ${e.response?.data}');
      return {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };
    } catch (e) {
      print('[EnrolledCourseService] Lỗi không xác định: $e');
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
