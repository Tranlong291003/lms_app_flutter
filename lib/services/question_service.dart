import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/services/base_service.dart';

class QuestionService extends BaseService {
  QuestionService({super.token});

  Future<List<QuestionModel>> getQuestionsByQuizId(
    int quizId, {
    int? maxQuestions,
  }) async {
    try {
      print(
        'QuestionService: Đang gọi API lấy câu hỏi cho bài kiểm tra $quizId',
      );

      String url = ApiConfig.getQuestionsByQuizId(quizId);
      // Thêm tham số limit nếu có giới hạn số lượng câu hỏi
      if (maxQuestions != null) {
        url += '${url.contains('?') ? '&' : '?'}limit=$maxQuestions';
      }

      final response = await get(url);
      print('QuestionService: Nhận được dữ liệu từ API: ${response.data}');

      final List<dynamic> data = response.data['data'];
      final questions =
          data.map((json) => QuestionModel.fromJson(json)).toList();

      print('QuestionService: Đã xử lý ${questions.length} câu hỏi');

      // Trong trường hợp API không hỗ trợ giới hạn, chúng ta tự giới hạn ở phía client
      if (maxQuestions != null && questions.length > maxQuestions) {
        // Trộn ngẫu nhiên danh sách câu hỏi và chỉ lấy maxQuestions câu
        questions.shuffle();
        return questions.take(maxQuestions).toList();
      }

      return questions;
    } catch (e) {
      print('QuestionService: Lỗi khi lấy câu hỏi: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitQuizResult(
    int quizId,
    String userUid,
    Map<String, int?> answers,
    String? explanation,
  ) async {
    try {
      print('QuestionService: Đang gọi API nộp bài kiểm tra $quizId');
      print('QuestionService: Dữ liệu gửi đi:');
      print('- userUid: $userUid');
      print('- answers: $answers');
      print('- explanation: $explanation');

      final Map<String, dynamic> payload = {
        'uid': userUid,
        'quiz_id': quizId,
        'answers': answers,
      };

      if (explanation != null && explanation.isNotEmpty) {
        payload['explanation'] = explanation;
      }

      // Endpoint API nộp bài kiểm tra
      final response = await post(
        '${ApiConfig.baseUrl}/api/quiz-results/submit',
        data: payload,
      );
      print('QuestionService: Nhận được kết quả từ API: ${response.data}');

      // API trả về 201 là thành công
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': {
            'score': response.data['score'],
            'totalQuestions': response.data['total_questions'],
            'correctAnswers': response.data['correct_answers'],
            'invalidQuestionIds': response.data['invalid_question_ids'],
            'result_id': response.data['result_id'],
          },
          'result_id': response.data['result_id'],
          'message': response.data['message'] ?? 'Nộp bài thành công',
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Lỗi không xác định khi nộp bài',
          'errorDetails': response.data['error_details'],
        };
      }
    } catch (e) {
      print('QuestionService: Lỗi khi nộp bài kiểm tra: $e');
      if (e is DioException) {
        print('QuestionService: DioException details:');
        print('- Type: ${e.type}');
        print('- Message: ${e.message}');
        print('- Response: ${e.response?.data}');
        print('- Status code: ${e.response?.statusCode}');
      }
      return {'success': false, 'message': 'Lỗi khi nộp bài: $e'};
    }
  }

  Future<Map<String, dynamic>> getQuizResultDetails(int resultId) async {
    try {
      print(
        'QuestionService: Đang lấy chi tiết kết quả bài kiểm tra $resultId',
      );

      final response = await get(ApiConfig.getQuizResultDetails(resultId));
      print('QuestionService: Nhận được dữ liệu từ API: ${response.data}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': response.data['message'] ?? 'Lấy kết quả thành công',
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['message'] ?? 'Lỗi không xác định khi lấy kết quả',
        };
      }
    } catch (e) {
      print('QuestionService: Lỗi khi lấy chi tiết kết quả bài kiểm tra: $e');
      if (e is DioException) {
        print('QuestionService: DioException details:');
        print('- Type: ${e.type}');
        print('- Message: ${e.message}');
        print('- Response: ${e.response?.data}');
        print('- Status code: ${e.response?.statusCode}');
      }
      return {'success': false, 'message': 'Lỗi khi lấy kết quả: $e'};
    }
  }
}
