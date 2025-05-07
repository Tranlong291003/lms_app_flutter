import 'package:dio/dio.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/services/course_service.dart';

class CourseRepository {
  final CourseService _service;
  CourseRepository(Dio dio) : _service = CourseService(dio);

  /// Lấy danh sách khóa học với filter status, category, search
  Future<List<Course>> getAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    final raw = await _service.fetchAllCourses(
      status: status,
      categoryId: categoryId,
      search: search,
    );
    return raw.map((e) => Course.fromJson(e)).toList();
  }
}
