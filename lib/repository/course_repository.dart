import 'package:dio/dio.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/services/course_service.dart';

class CourseRepository {
  final CourseService _service;
  CourseRepository(Dio dio) : _service = CourseService(dio);

  Future<List<Course>> getAllCourses() async {
    final raw = await _service.fetchAllCourses();
    return raw.map((e) => Course.fromJson(e)).toList();
  }
}
