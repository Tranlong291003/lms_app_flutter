import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/services/base_service.dart';

class CourseService extends BaseService {
  CourseService({super.token});

  /// Lấy danh sách khóa học với filter tùy chọn
  Future<List<Map<String, dynamic>>> fetchAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (status?.trim().isNotEmpty ?? false) {
      params['status'] = status!.trim();
    }
    if (categoryId != null) params['category'] = categoryId;
    if (search?.trim().isNotEmpty ?? false) {
      params['search'] = search!.trim();
    }

    try {
      final response = await get(
        ApiConfig.getAllCourses,
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            return List<Map<String, dynamic>>.from(data['data'] as List);
          }
          if (data['message'] != null) {
            throw Exception(data['message'] as String);
          }
        }
      }
      throw Exception(
        'Không thể tải danh sách khóa học (status: ${response.statusCode})',
      );
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách khóa học: $e');
    }
  }

  /// Lấy chi tiết khóa học theo ID
  Future<CourseDetail> getCourseDetail(int courseId) async {
    try {
      final response = await get('${ApiConfig.getAllCourses}/$courseId');

      if (response.statusCode == 200 &&
          response.data['data'] is Map<String, dynamic>) {
        return CourseDetail.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Không thể tải chi tiết khóa học');
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết khóa học: $e');
    }
  }

  /// Kiểm tra người dùng đã đăng ký khoá học chưa
  Future<bool> checkEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    try {
      final response = await get(ApiConfig.checkEnrollment(userUid, courseId));
      // print(
      //   '[CourseService] Response status: [35m${response.statusCode}[0m, data: [33m${response.data}[0m',
      // );
      if (response.statusCode == 200) {
        final data = response.data;
        // print('[CourseService] Parsed data: [36m$data[0m');
        if (data is bool) return data;
        if (data is Map<String, dynamic> && data.containsKey('enrolled')) {
          // print(
          //   '[CourseService] Trả về enrolled = [32m${data['enrolled']}[0m',
          // );
          return data['enrolled'] == true;
        }
        // print('[CourseService] Không có trường enrolled, trả về false');
        return false;
      }
      // print('[CourseService] Status khác 200, trả về false');
      return false;
    } catch (e) {
      // print('[CourseService] Lỗi khi kiểm tra đăng ký: [31m$e[0m');
      return false;
    }
  }

  Future<dynamic> registerEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    // print(
    //   '[CourseService] Gọi đăng ký khoá học: userUid=$userUid, courseId=$courseId',
    // );
    try {
      final data = {'userUid': userUid, 'courseId': courseId};
      // print('[CourseService] Dữ liệu gửi lên: $data');
      final response = await post(ApiConfig.registerEnrollment, data: data);
      // print(
      //   '[CourseService] Response: status=${response.statusCode}, data=${response.data}',
      // );
      if (response.data is Map && response.data['notification'] != null) {
        // print('[CourseService] Trả về Map có notification');
        return response.data;
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (e is DioException && e.response != null) {
        // print(
        //   '[CourseService] Lỗi đăng ký khoá học: status=${e.response?.statusCode}, data=${e.response?.data}',
        // );
      } else {
        // print('[CourseService] Lỗi đăng ký khoá học: $e');
      }
      throw Exception('Đăng ký khoá học thất bại: $e');
    }
  }
}
