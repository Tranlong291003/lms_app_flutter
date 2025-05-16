import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/quiz/quiz_cubit.dart';
import 'package:lms/models/quiz/quiz_result_model.dart';
import 'package:lms/repository/question_repository.dart';
import 'package:lms/services/question_service.dart';

class QuizResultDetailScreen extends StatelessWidget {
  const QuizResultDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? resultId = args != null ? args['resultId'] as int? : null;
    if (resultId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kết quả kiểm tra')),
        body: const Center(child: Text('Không tìm thấy kết quả.')),
      );
    }
    return BlocProvider(
      create:
          (_) =>
              QuizResultCubit(QuestionRepository(QuestionService()))
                ..fetchQuizResult(resultId),
      child: const _QuizResultDetailView(),
    );
  }
}

class _QuizResultDetailView extends StatelessWidget {
  const _QuizResultDetailView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả kiểm tra')),
      body: BlocBuilder<QuizResultCubit, QuizResultState>(
        builder: (context, state) {
          if (state is QuizResultLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QuizResultError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is QuizResultLoaded) {
            final QuizResultModel result = state.result;
            final score = result.score;
            final questions = result.detailedResults;
            final totalQuestions = result.totalQuestions;
            final correctAnswers = result.correctAnswers;
            final wrongAnswers = result.incorrectAnswers;
            final unanswered = result.unansweredQuestions;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (Theme.of(context).brightness == Brightness.light)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                      ],
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.blue,
                          size: 36,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${score.toStringAsFixed(1)} điểm',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStat(
                              context,
                              icon: Icons.check_circle,
                              color: Colors.green,
                              label: 'Đúng',
                              value: correctAnswers,
                            ),
                            const SizedBox(width: 24),
                            _buildStat(
                              context,
                              icon: Icons.cancel,
                              color: Colors.red,
                              label: 'Sai',
                              value: wrongAnswers,
                            ),
                            const SizedBox(width: 24),
                            _buildStat(
                              context,
                              icon: Icons.help_outline,
                              color: Colors.grey,
                              label: 'Chưa trả lời',
                              value: unanswered,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tổng số câu: $totalQuestions',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chi tiết từng câu hỏi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (questions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Không có dữ liệu câu hỏi',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    )
                  else
                    ...questions.asMap().entries.map((entry) {
                      final i = entry.key;
                      final q = entry.value as Map<String, dynamic>;
                      return _buildQuestionDetail(context, i, q);
                    }),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildQuestionDetail(
    BuildContext context,
    int index,
    Map<String, dynamic> q,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCorrect = q['is_correct'] == true;
    final userAnswerIdx = q['user_answer'];
    final correctAnswerIdx = q['correct_answer'];
    final options = (q['options'] as List<dynamic>).cast<String>();
    final userAnswer =
        (userAnswerIdx != null &&
                userAnswerIdx is int &&
                userAnswerIdx >= 0 &&
                userAnswerIdx < options.length)
            ? options[userAnswerIdx]
            : null;
    final correctAnswer =
        (correctAnswerIdx != null &&
                correctAnswerIdx is int &&
                correctAnswerIdx >= 0 &&
                correctAnswerIdx < options.length)
            ? options[correctAnswerIdx]
            : null;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCorrect
                  ? Colors.green
                  : (userAnswer == null ? Colors.grey : Colors.red),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor:
                    isCorrect
                        ? Colors.green
                        : (userAnswer == null ? Colors.grey : Colors.red),
                radius: 14,
                child: Icon(
                  isCorrect
                      ? Icons.check
                      : (userAnswer == null ? Icons.help_outline : Icons.close),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Câu ${index + 1}: ${q['question']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child:
                    userAnswer != null
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Bạn chọn: ',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 13,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                userAnswer,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
              Expanded(
                child:
                    (userAnswer == null || userAnswerIdx != correctAnswerIdx)
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đáp án đúng: ',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                correctAnswer ?? '',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...options.asMap().entries.map((entry) {
            final i = entry.key;
            final option = entry.value;
            final isUser = userAnswerIdx == i;
            final isRight = correctAnswerIdx == i;
            return Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minWidth: 0,
                maxWidth: double.infinity,
              ),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    isRight
                        ? Colors.green.withOpacity(0.12)
                        : (isUser
                            ? Colors.blue.withOpacity(0.10)
                            : colorScheme.surface),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isRight
                          ? Colors.green
                          : (isUser
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.15)),
                  width: isRight || isUser ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRight)
                    const Icon(Icons.check, color: Colors.green, size: 18),
                  if (!isRight && isUser)
                    const Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue,
                      size: 18,
                    ),
                  if (!isRight && !isUser) const SizedBox(width: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color:
                            isRight
                                ? Colors.green
                                : (isUser
                                    ? colorScheme.primary
                                    : colorScheme.onSurface),
                        fontWeight:
                            isRight || isUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (q['explanation'] != null &&
              (q['explanation'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.smart_toy,
                    color: Colors.deepPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Giải thích AI:',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q['explanation'],
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
