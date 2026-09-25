// test/quiz_scoring_test.dart
//
// Chấm điểm bài kiểm tra — hồi quy cho hai lỗi đã gặp:
//
// 1. Câu BỎ TRỐNG bị tính là ĐÚNG. `userAnswers` khởi tạo bằng `-1` cho mọi
//    câu, và một số câu hỏi cũ không có `correct_index` nên model cũng mặc định
//    `-1` → phép so sánh `-1 == -1` luôn đúng.
// 2. Điểm chia cho TỔNG số câu thay vì số câu ĐÃ TRẢ LỜI, nên bỏ trống bị trừ
//    điểm oan. API tính `correct / totalAnswered * 10`.
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/cubits/question/question_cubit.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/services/question_service.dart';

QuestionModel _question(int id, {int correctIndex = 0, List<String>? options}) {
  return QuestionModel(
    questionId: id,
    quizId: 1,
    question: 'Câu $id',
    options: options ?? const ['A', 'B', 'C', 'D'],
    correctIndex: correctIndex,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('QuestionModel.getCorrectAnswer', () {
    test('correctIndex âm trả "Không có đáp án" thay vì ném RangeError', () {
      // Dữ liệu thật: quiz 131 có câu không kèm `correct_index` → model để -1.
      final q = _question(1, correctIndex: -1);
      expect(q.getCorrectAnswer(), 'Không có đáp án');
    });

    test('correctIndex vượt số đáp án trả "Không có đáp án"', () {
      final q = _question(1, correctIndex: 9);
      expect(q.getCorrectAnswer(), 'Không có đáp án');
    });

    test('correctIndex hợp lệ trả đúng đáp án', () {
      final q = _question(1, correctIndex: 2);
      expect(q.getCorrectAnswer(), 'C');
    });
  });

  group('QuestionCubit chấm điểm', () {
    /// Cubit với state đặt sẵn — các test này chỉ kiểm tra logic chấm điểm
    /// thuần tuý nên không gọi mạng; repository thật không bao giờ được dùng.
    QuestionCubit cubitWith(
      List<QuestionModel> questions,
      List<int> answers,
    ) {
      final cubit = QuestionCubit(QuestionRepository(QuestionService()));
      cubit.emit(
        cubit.state.copyWith(questions: questions, userAnswers: answers),
      );
      return cubit;
    }

    test('câu bỏ trống KHÔNG được tính là đúng (correct_index = -1)', () {
      // Đúng dữ liệu đã gây lỗi: cả hai câu đều có correctIndex -1 và đều bỏ
      // trống. Trước đây ra 2 câu đúng.
      final cubit = cubitWith(
        [_question(1, correctIndex: -1), _question(2, correctIndex: -1)],
        [-1, -1],
      );
      expect(cubit.getCorrectAnswersCount(), 0);
      expect(cubit.answeredCount, 0);
      expect(cubit.getScore(), 0);
    });

    test('câu bỏ trống không bị trừ điểm (chia cho số câu đã trả lời)', () {
      // 4 câu, chỉ trả lời 2, trong đó 1 đúng.
      // Công thức API: 1/2 * 10 = 5.0 (không phải 1/4 * 10 = 2.5).
      final cubit = cubitWith(
        [
          _question(1, correctIndex: 0),
          _question(2, correctIndex: 1),
          _question(3, correctIndex: 2),
          _question(4, correctIndex: 3),
        ],
        [0, 3, -1, -1],
      );
      expect(cubit.getCorrectAnswersCount(), 1);
      expect(cubit.answeredCount, 2);
      expect(cubit.getScore(), 5.0);
    });

    test('trả lời hết và đúng hết thì điểm tối đa', () {
      final cubit = cubitWith(
        [_question(1, correctIndex: 0), _question(2, correctIndex: 1)],
        [0, 1],
      );
      expect(cubit.getCorrectAnswersCount(), 2);
      expect(cubit.getScore(), 10.0);
    });

    test('điểm ưu tiên lấy từ server khi đã nộp bài', () {
      final cubit = cubitWith(
        [_question(1, correctIndex: 0), _question(2, correctIndex: 1)],
        [0, -1],
      );
      // Trước khi nộp: chưa có điểm server.
      expect(cubit.serverScore, isNull);

      cubit.emit(
        cubit.state.copyWith(
          quizResult: {
            'success': true,
            'score': 7.5,
            'data': {'correctAnswers': 3, 'totalAnswered': 4},
          },
        ),
      );
      expect(cubit.serverScore, 7.5);
      expect(cubit.serverCorrectAnswers, 3);
    });
  });
}
