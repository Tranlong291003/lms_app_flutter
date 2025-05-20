import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/services/base_service.dart';

class QuizService extends BaseService {
  QuizService({super.token});

  Future<Map<String, dynamic>> getQuizzesByUser(String userUid) async {
    try {
      print(
        'QuizService: Đang gọi API lấy bài kiểm tra cho người dùng $userUid',
      );
      final response = await get(ApiConfig.getQuizzesByUser(userUid));
      print('QuizService: Nhận được dữ liệu quiz từ API: ${response.data}');

      final Map<String, dynamic> responseData = response.data;
      final Map<String, dynamic> result = {
        'enrolledCourses': [],
        'notEnrolledCourses': [],
      };

      // Xử lý dữ liệu khóa học đã đăng ký
      if (responseData['data'] != null &&
          responseData['data']['enrolledCourses'] != null) {
        final List<dynamic> enrolledData =
            responseData['data']['enrolledCourses'];
        result['enrolledCourses'] = _processCoursesData(enrolledData);
      }

      // Xử lý dữ liệu khóa học chưa đăng ký
      if (responseData['data'] != null &&
          responseData['data']['notEnrolledCourses'] != null) {
        final List<dynamic> notEnrolledData =
            responseData['data']['notEnrolledCourses'];
        result['notEnrolledCourses'] = _processCoursesData(notEnrolledData);
      }

      print('QuizService: Đã xử lý dữ liệu thành công');
      return result;
    } catch (e) {
      print('QuizService: Lỗi khi lấy bài kiểm tra: $e');
      rethrow;
    }
  }

  List<Map<String, dynamic>> _processCoursesData(List<dynamic> coursesData) {
    return coursesData.map<Map<String, dynamic>>((courseData) {
      final Map<String, dynamic> courseMap = {
        'courseId': courseData['course_id'],
        'courseTitle': courseData['course_title'],
        'quizzes': <QuizModel>[],
      };

      if (courseData['quizzes'] != null) {
        courseMap['quizzes'] =
            (courseData['quizzes'] as List)
                .map((quizJson) => QuizModel.fromJson(quizJson))
                .toList();
      }

      return courseMap;
    }).toList();
  }

  Future<List<QuizResultModel>> getUserQuizResults(String userUid) async {
    try {
      print('QuizService: Gọi API lấy kết quả đã làm cho user $userUid');
      final response = await get(
        '${ApiConfig.baseUrl}/api/quiz-results/users/$userUid/results',
      );
      print('QuizService: Nhận dữ liệu từ API: ${response.data}');
      if (response.statusCode == 200 && response.data['results'] != null) {
        final List<dynamic> data = response.data['results'];
        print('QuizService: Số lượng kết quả: ${data.length}');
        return data.map((e) => QuizResultModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('QuizService: Lỗi khi lấy danh sách kết quả đã làm: $e');
      return [];
    }
  }

  Future<List<QuizModel>> getQuizzesByCourseId(int courseId) async {
    try {
      final response = await get(
        'http://192.168.10.203:3000/api/quizzes/getquizbycoures/$courseId',
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => QuizModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('QuizService: Lỗi khi lấy quiz theo courseId: $e');
      return [];
    }
  }

  Future<bool> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await post(
        'http://192.168.10.203:3000/api/quizzes/create',
        data: data,
      );
      return response.statusCode == 201;
    } catch (e) {
      print('QuizService: Lỗi khi tạo quiz: $e');
      return false;
    }
  }

  Future<bool> updateQuiz(int quizId, Map<String, dynamic> data) async {
    try {
      final response = await put(
        'http://192.168.10.203:3000/api/quizzes/update/$quizId',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('QuizService: Lỗi khi cập nhật quiz: $e');
      return false;
    }
  }

  Future<bool> deleteQuiz(int quizId, Map<String, dynamic> data) async {
    try {
      final response = await delete(
        'http://192.168.10.203:3000/api/quizzes/delete/$quizId',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('QuizService: Lỗi khi xoá quiz: $e');
      return false;
    }
  }
}
