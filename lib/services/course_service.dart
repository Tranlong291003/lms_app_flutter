import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';

class CourseService {
  final Dio _dio;
  CourseService(Dio dio) : _dio = dio;

  Future<List<Map<String, dynamic>>> fetchAllCourses() async {
    final res = await _dio.get(ApiConfig.getAllCourses);
    if (res.statusCode == 200 && res.data is List) {
      return List<Map<String, dynamic>>.from(res.data as List);
    }
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      final map = res.data as Map<String, dynamic>;
      if (map['data'] is List) {
        return List<Map<String, dynamic>>.from(map['data'] as List);
      }
    }
    throw Exception('Failed to load courses (status: \${res.statusCode})');
  }
}
