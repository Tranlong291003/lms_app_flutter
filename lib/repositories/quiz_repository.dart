import 'package:lms/models/quiz/quiz_course_model.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/quiz_service.dart';

class QuizRepository extends BaseRepository<QuizService> {
  QuizRepository(super.service);

  Future<Map<String, List<QuizCourseModel>>> getQuizzesByUser(
    String userUid,
  ) async {
    try {
      print(
        'QuizRepository: Đang lấy danh sách bài kiểm tra cho user: $userUid',
      );
      final Map<String, dynamic> result = await service.getQuizzesByUser(
        userUid,
      );

      // Xử lý dữ liệu enrolled courses
      final List<QuizCourseModel> enrolledCourses =
          (result['enrolledCourses'] as List)
              .map((courseData) => QuizCourseModel.fromJson(courseData))
              .toList();

      // Xử lý dữ liệu not enrolled courses
      final List<QuizCourseModel> notEnrolledCourses =
          (result['notEnrolledCourses'] as List)
              .map((courseData) => QuizCourseModel.fromJson(courseData))
              .toList();

      print(
        'QuizRepository: Đã xử lý được ${enrolledCourses.length} khóa học đã đăng ký',
      );
      print(
        'QuizRepository: Đã xử lý được ${notEnrolledCourses.length} khóa học chưa đăng ký',
      );

      return {
        'enrolledCourses': enrolledCourses,
        'notEnrolledCourses': notEnrolledCourses,
      };
    } catch (e) {
      print('Lỗi Repository khi lấy danh sách bài kiểm tra: $e');
      rethrow;
    }
  }

  Future<List<QuizResultModel>> getUserQuizResults(String userUid) async {
    print('QuizRepository: Lấy danh sách kết quả đã làm cho user: $userUid');
    final results = await service.getUserQuizResults(userUid);
    print('QuizRepository: Đã lấy được ${results.length} kết quả');
    return results;
  }
}
