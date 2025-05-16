import 'package:flutter/material.dart';

class QuizProgress extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int answeredCount;

  const QuizProgress({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answeredCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = answeredCount / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Câu hỏi ${currentQuestion + 1}/$totalQuestions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Đã trả lời: $answeredCount/$totalQuestions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            // Background progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Progress indicator
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
