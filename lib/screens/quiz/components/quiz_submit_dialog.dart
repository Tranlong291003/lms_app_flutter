import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_theme.dart';

class QuizSubmitDialog extends StatelessWidget {
  final int totalAnswered;
  final int totalQuestions;
  final String explanationText;
  final Function(String) onExplanationChanged;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const QuizSubmitDialog({
    super.key,
    required this.totalAnswered,
    required this.totalQuestions,
    required this.explanationText,
    required this.onExplanationChanged,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = AppColors.of(context);
    final hasUnansweredQuestions = totalAnswered < totalQuestions;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Xác nhận nộp bài'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn đã trả lời $totalAnswered/$totalQuestions câu hỏi',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          if (hasUnansweredQuestions) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: semantic.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: semantic.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn còn ${totalQuestions - totalAnswered} câu chưa trả lời. Bạn có chắc chắn muốn nộp bài?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: semantic.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: semantic.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: semantic.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: semantic.success, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn đã trả lời tất cả các câu hỏi!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: semantic.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Explanation field
          TextField(
            onChanged: onExplanationChanged,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Giải thích (không bắt buộc)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Hủy')),
        ElevatedButton(
          onPressed: onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Nộp bài'),
        ),
      ],
    );
  }
}
