import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/json_parse.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/services/base_service.dart';

class QuestionService extends BaseService {
  QuestionService({super.token});

  /// Lấy danh sách câu hỏi của một quiz.
  ///
  /// `GET /api/questions/:quiz_id` trả `correct_index` **0-based** (để so sánh
  /// trực tiếp với `options[i]`).
  Future<List<QuestionModel>> getQuestionsByQuizId(
    int quizId, {
    int? maxQuestions,
  }) async {
    try {
      final response = await get(ApiConfig.getQuestionsByQuizId(quizId));

      if (response.data['data'] is! List) {
        return [];
      }

      var questions = (response.data['data'] as List)
          .map(
            (json) => QuestionModel.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();

      if (maxQuestions != null && questions.length > maxQuestions) {
        questions.shuffle();
        questions = questions.take(maxQuestions).toList();
      }

      return questions;
    } on DioException catch (e) {
      // 404 = quiz chưa có câu hỏi nào, không phải lỗi hiển thị cho người dùng.
      if (e.response?.statusCode == 404) return [];
      throw Exception(
        'Không thể tải danh sách câu hỏi: ${extractApiError(e)}',
      );
    }
  }

  /// Nộp bài làm.
  ///
  /// `POST /api/quiz-results/submit` body
  /// `{ uid?, quiz_id, answers: { question_id: index 0-based }, explanation? }`
  /// → `201 { result_id, score, total_answered, correct_answers,
  /// invalid_question_ids, questions }`.
  Future<Map<String, dynamic>> submitQuizResult(
    int quizId,
    String userUid,
    Map<String, int?> answers,
    String? explanation,
  ) async {
    try {
      final payload = <String, dynamic>{
        'uid': userUid,
        'quiz_id': quizId,
        'answers': answers,
        if (explanation != null && explanation.isNotEmpty)
          'explanation': explanation,
      };

      final response = await post(ApiConfig.submitQuizResult, data: payload);
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': {
            'score': asDouble(data['score']),
            'totalQuestions': asInt(data['total_answered']),
            'totalAnswered': asInt(data['total_answered']),
            'correctAnswers': asInt(data['correct_answers']),
            'invalidQuestionIds': data['invalid_question_ids'] ?? [],
            'questions': data['questions'] ?? [],
            'result_id': data['result_id'],
          },
          'result_id': data['result_id'],
          'score': asDouble(data['score']),
          'message': data['message'] ?? 'Nộp bài thành công',
        };
      }

      return {
        'success': false,
        'message': data['error'] ?? data['message'] ?? 'Lỗi không xác định khi nộp bài',
      };
    } catch (e) {
      print('QuestionService: Lỗi khi nộp bài kiểm tra: $e');
      return {
        'success': false,
        'message': 'Lỗi khi nộp bài: ${extractApiError(e, fallback: '$e')}',
      };
    }
  }

  /// Chi tiết một lượt làm bài.
  ///
  /// Lưu ý: endpoint này gọi OpenAI để sinh giải thích cho các câu sai nên có
  /// thể chậm; `quizResultData` giữ nguyên cấu trúc `data` của API.
  Future<Map<String, dynamic>> getQuizResultDetails(int resultId) async {
    try {
      final response = await get(ApiConfig.getQuizResultDetails(resultId));

      if (response.statusCode == 200) {
        final data = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        return {
          'success': true,
          'data': data['data'],
          'message': data['message'] ?? 'Lấy kết quả thành công',
        };
      }

      return {
        'success': false,
        'message': 'Lỗi không xác định khi lấy kết quả',
      };
    } catch (e) {
      print('QuestionService: Lỗi khi lấy chi tiết kết quả: $e');
      return {
        'success': false,
        'message': 'Lỗi khi lấy kết quả: ${extractApiError(e, fallback: '$e')}',
      };
    }
  }

  /// Cập nhật câu hỏi.
  ///
  /// API nhận `correct_index` **1-based** khi ghi (`1` = đáp án đầu tiên) và
  /// trả về **0-based** khi đọc, nên phải cộng 1 trước khi gửi.
  Future<bool> updateQuestion(int questionId, Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{...data};
      if (payload['correct_index'] is int) {
        payload['correct_index'] = (payload['correct_index'] as int) + 1;
      }
      final response = await put(
        ApiConfig.updateQuestion(questionId),
        data: payload,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('QuestionService: Lỗi khi cập nhật câu hỏi: $e');
      return false;
    }
  }

  Future<bool> deleteQuestion(int questionId, Map<String, dynamic> data) async {
    try {
      final response = await delete(
        ApiConfig.deleteQuestion(questionId),
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('QuestionService: Lỗi khi xoá câu hỏi: $e');
      return false;
    }
  }

  /// Tạo câu hỏi bằng tay (`correct_index` gửi lên là 1-based).
  Future<bool> createQuestionManual(Map<String, dynamic> data) async {
    try {
      final payload = <String, dynamic>{...data};
      if (payload['correct_index'] is int) {
        payload['correct_index'] = (payload['correct_index'] as int) + 1;
      }
      final response = await post(ApiConfig.createQuestionManual, data: payload);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('QuestionService: Lỗi khi tạo câu hỏi bằng tay: $e');
      return false;
    }
  }

  /// Tạo câu hỏi bằng AI.
  Future<bool> createQuestionAI(Map<String, dynamic> data) async {
    try {
      final response = await post(ApiConfig.createQuestionAI, data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('QuestionService: Lỗi khi tạo câu hỏi bằng AI: $e');
      return false;
    }
  }
}
