import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/question_service.dart';

class QuestionRepository extends BaseRepository<QuestionService> {
  QuestionRepository(super.service);

  Future<List<QuestionModel>> getQuestionsByQuizId(
    int quizId, {
    int? maxQuestions,
  }) async {
    try {
      print(
        'QuestionRepository: Đang lấy danh sách câu hỏi cho bài kiểm tra: $quizId',
      );

      final questions = await service.getQuestionsByQuizId(
        quizId,
        maxQuestions: maxQuestions,
      );
      print('QuestionRepository: Đã nhận được ${questions.length} câu hỏi');
      return questions;
    } catch (e) {
      print('Lỗi Repository khi lấy danh sách câu hỏi: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitQuizResult(
    int quizId,
    String userUid,
    Map<String, int?> answers,
    List<QuestionModel> questions, {
    String? explanation,
  }) async {
    try {
      print('QuestionRepository: Đang nộp kết quả bài kiểm tra $quizId');
      print('QuestionRepository: Dữ liệu đầu vào:');
      print('- userUid: $userUid');
      print('- answers: $answers');
      print('- questions: ${questions.length} câu hỏi');
      print('- explanation: $explanation');

      final result = await service.submitQuizResult(
        quizId,
        userUid,
        answers,
        explanation,
      );

      print('QuestionRepository: Kết quả từ service:');
      print('- success: ${result['success']}');
      print('- message: ${result['message']}');
      if (result['data'] != null) {
        print('- data: ${result['data']}');
      }

      return result;
    } catch (e) {
      print('QuestionRepository: Lỗi khi nộp kết quả bài kiểm tra: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getQuizResultDetails(int resultId) async {
    try {
      print(
        'QuestionRepository: Đang lấy chi tiết kết quả bài kiểm tra $resultId',
      );

      final result = await service.getQuizResultDetails(resultId);

      print('QuestionRepository: Kết quả từ service:');
      print('- success: ${result['success']}');
      print('- message: ${result['message']}');
      if (result['data'] != null) {
        print('- data: ${result['data']}');
      }

      return result;
    } catch (e) {
      print(
        'QuestionRepository: Lỗi khi lấy chi tiết kết quả bài kiểm tra: $e',
      );
      rethrow;
    }
  }

  Future<bool> updateQuestion(int questionId, Map<String, dynamic> data) async {
    return await service.updateQuestion(questionId, data);
  }

  Future<bool> deleteQuestion(int questionId, Map<String, dynamic> data) async {
    return await service.deleteQuestion(questionId, data);
  }

  /// Tạo câu hỏi bằng tay
  Future<bool> createQuestionManual(Map<String, dynamic> data) async {
    try {
      print('QuestionRepository: Đang tạo câu hỏi bằng tay');
      return await service.createQuestionManual(data);
    } catch (e) {
      print('QuestionRepository: Lỗi khi tạo câu hỏi bằng tay: $e');
      return false;
    }
  }

  /// Tạo câu hỏi bằng AI
  Future<bool> createQuestionAI(Map<String, dynamic> data) async {
    try {
      print('QuestionRepository: Đang tạo câu hỏi bằng AI');
      return await service.createQuestionAI(data);
    } catch (e) {
      print('QuestionRepository: Lỗi khi tạo câu hỏi bằng AI: $e');
      return false;
    }
  }
}
