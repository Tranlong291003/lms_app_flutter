import 'package:lms/models/enrolledCourse_model.dart';
import 'package:lms/repository/base_repository.dart';
import 'package:lms/services/enrolled_course_service.dart';

class EnrolledCourseRepository extends BaseRepository<EnrolledCourseService> {
  EnrolledCourseRepository({String? token})
    : super(EnrolledCourseService(token: token));

  /// Lấy danh sách khóa học đã đăng ký của người dùng
  Future<Map<String, List<EnrolledCourse>>> getEnrolledCourses(
    String userUid,
  ) async {
    try {
      print(
        '[EnrolledCourseRepository] Bắt đầu lấy khóa học đã đăng ký cho user: $userUid',
      );
      final result = await service.getEnrolledCourses(userUid);

      // In ra thông tin chi tiết về các khóa học để debug
      final inProgress = result['in_progress'] ?? [];
      final completed = result['completed'] ?? [];

      print(
        '[EnrolledCourseRepository] Đã lấy được ${inProgress.length} khóa học đang học và ${completed.length} khóa học đã hoàn thành',
      );

      // In thông tin chi tiết về khóa học đang học
      for (var i = 0; i < inProgress.length; i++) {
        final course = inProgress[i];
        print(
          '[EnrolledCourseRepository] Khóa học đang học #$i: ID=${course.courseId}, Tiêu đề=${course.title}, Hoàn thành=${course.completedLessons}/${course.totalLessons}',
        );
      }

      // In thông tin chi tiết về khóa học đã hoàn thành
      for (var i = 0; i < completed.length; i++) {
        final course = completed[i];
        print(
          '[EnrolledCourseRepository] Khóa học đã hoàn thành #$i: ID=${course.courseId}, Tiêu đề=${course.title}, Hoàn thành=${course.completedLessons}/${course.totalLessons}',
        );
      }

      return result;
    } catch (e) {
      print('[EnrolledCourseRepository] Lỗi khi lấy khóa học đã đăng ký: $e');
      // Trả về danh sách rỗng thay vì ném lỗi để tránh làm crash ứng dụng
      return {
        'in_progress': <EnrolledCourse>[],
        'completed': <EnrolledCourse>[],
      };
    }
  }
}
