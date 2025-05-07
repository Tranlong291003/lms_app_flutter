import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';

class CourseService {
  final Dio _dio;
  CourseService(Dio dio) : _dio = dio;

  /// Lấy danh sách khóa học với filter tùy chọn
  Future<List<Map<String, dynamic>>> fetchAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    // Chuẩn bị query parameters
    final params = <String, dynamic>{};
    if (status != null && status.trim().isNotEmpty)
      params['status'] = status.trim();
    if (categoryId != null) params['category'] = categoryId;
    if (search != null && search.trim().isNotEmpty)
      params['search'] = search.trim();

    // Gọi API với params nếu có
    final res = await _dio.get(
      ApiConfig.getAllCourses,
      queryParameters: params.isEmpty ? null : params,
    );

    // Xử lý response
    if (res.statusCode == 200) {
      final data = res.data;
      // Trường hợp trả về List trực tiếp
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
      // Trường hợp trả về {'data': [...]}
      if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'] as List);
        }
        // Trường hợp API trả về message khi không có khóa học
        if (data['message'] != null) {
          throw Exception(data['message'] as String);
        }
      }
    }
    // Các trường hợp khác throw exception
    throw Exception('Failed to load courses (status: \${res.statusCode})');
  }
}
