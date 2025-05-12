import 'package:dio/dio.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repository/base_repository.dart';
import 'package:lms/services/course_service.dart';

class CourseRepository extends BaseRepository<CourseService> {
  CourseRepository(Dio dio) : super(CourseService());

  /// Lấy danh sách khóa học với filter status, category, search
  Future<List<Course>> getAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    final raw = await service.fetchAllCourses(
      status: status,
      categoryId: categoryId,
      search: search,
    );
    return raw.map((e) => Course.fromJson(e)).toList();
  }

  Future<CourseDetail> getCourseDetail(int courseId) async {
    return await service.getCourseDetail(courseId);
  }

  Future<dynamic> registerEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    print(
      '[CourseRepository] Gọi đăng ký khoá học: userUid=$userUid, courseId=$courseId',
    );
    try {
      final result = await service.registerEnrollment(
        userUid: userUid,
        courseId: courseId,
      );
      print('[CourseRepository] Kết quả trả về từ service: $result');
      if (result is Map) {
        print('[CourseRepository] Trả về Map (có notification)');
        return result;
      }
      return result == true;
    } catch (e) {
      print('[CourseRepository] Lỗi khi đăng ký khoá học: $e');
      rethrow;
    }
  }
}
