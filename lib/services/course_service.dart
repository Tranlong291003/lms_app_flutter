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
}
