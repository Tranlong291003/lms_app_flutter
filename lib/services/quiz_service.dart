import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/services/base_service.dart';

class QuizService extends BaseService {
  QuizService({super.token});

  /// `GET /api/quizzes/getquizuser/:user_uid`
  /// → `{ data: { enrolledCourses: [{ course_id, course_title, quizzes }],
  ///              notEnrolledCourses: [...] } }`
  Future<Map<String, dynamic>> getQuizzesByUser(String userUid) async {
    try {
      final response = await get(ApiConfig.getQuizzesByUser(userUid));

      final result = <String, dynamic>{
        'enrolledCourses': <Map<String, dynamic>>[],
        'notEnrolledCourses': <Map<String, dynamic>>[],
      };

      final data = response.data is Map ? response.data['data'] : null;
      if (data is Map) {
        if (data['enrolledCourses'] is List) {
          result['enrolledCourses'] = _processCoursesData(
            data['enrolledCourses'] as List,
          );
        }
        if (data['notEnrolledCourses'] is List) {
          result['notEnrolledCourses'] = _processCoursesData(
            data['notEnrolledCourses'] as List,
          );
        }
      }

      return result;
    } catch (e) {
      print('QuizService: Lỗi khi lấy bài kiểm tra: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _processCoursesData(List<dynamic> coursesData) {
    return coursesData.map<Map<String, dynamic>>((courseData) {
      final map = Map<String, dynamic>.from(courseData as Map);
      return {
        'courseId': map['course_id'],
        'courseTitle': map['course_title'],
        'quizzes':
            map['quizzes'] is List
                ? (map['quizzes'] as List)
                    .map(
                      (quizJson) => QuizModel.fromJson(
                        Map<String, dynamic>.from(quizJson as Map),
                      ),
                    )
                    .toList()
                : <QuizModel>[],
      };
    }).toList();
  }

  /// `GET /api/quiz-results/users/:user_uid/results` → `{ total, results: [...] }`
  Future<List<QuizResultModel>> getUserQuizResults(String userUid) async {
    try {
      final response = await get(ApiConfig.getUserQuizResults(userUid));
      if (response.data is Map && response.data['results'] is List) {
        return (response.data['results'] as List)
            .map(
              (e) => QuizResultModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('QuizService: Lỗi khi lấy danh sách kết quả đã làm: $e');
      return [];
    }
  }

  /// `GET /api/quizzes/getquizbycourse/:course_id` → `{ data: [...] }`
  Future<List<QuizModel>> getQuizzesByCourseId(int courseId) async {
    try {
      final response = await get(ApiConfig.getQuizzesByCourseId(courseId));
      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map(
              (e) => QuizModel.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      // 404 = khóa học chưa có quiz nào.
      if (e.response?.statusCode == 404) return [];
      print('QuizService: Lỗi khi lấy quiz theo courseId: $e');
      return [];
    }
  }

  Future<bool> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await post(ApiConfig.createQuiz, data: data);
      return response.statusCode == 201;
    } catch (e) {
      print('QuizService: Lỗi khi tạo quiz: $e');
      return false;
    }
  }

  Future<bool> updateQuiz(int quizId, Map<String, dynamic> data) async {
    try {
      final response = await put(ApiConfig.updateQuiz(quizId), data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('QuizService: Lỗi khi cập nhật quiz: $e');
      return false;
    }
  }

  Future<bool> deleteQuiz(int quizId, Map<String, dynamic> data) async {
    try {
      final response = await delete(ApiConfig.deleteQuiz(quizId), data: data);
      return response.statusCode == 200;
    } catch (e) {
      print('QuizService: Lỗi khi xoá quiz: $e');
      return false;
    }
  }
}
