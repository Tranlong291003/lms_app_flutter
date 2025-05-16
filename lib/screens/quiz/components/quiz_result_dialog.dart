import 'package:flutter/material.dart';

class QuizResultDialog extends StatelessWidget {
  final int totalCorrect;
  final int totalQuestions;
  final double score;
  final int attemptsUsed;
  final int attemptLimit;
  final VoidCallback onClose;
  final VoidCallback? onRetry;
  final VoidCallback onViewDetails;

  const QuizResultDialog({
    super.key,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.score,
    required this.attemptsUsed,
    required this.attemptLimit,
    required this.onClose,
    this.onRetry,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final hasRemainingAttempts = attemptsUsed < attemptLimit;
    final percentage = (totalCorrect / totalQuestions * 100).toStringAsFixed(1);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Kết quả kiểm tra'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Score circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 4,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'điểm',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.check_circle,
                      label: 'Đúng',
                      value: '$totalCorrect câu',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.cancel,
                      label: 'Sai',
                      value: '${totalQuestions - totalCorrect} câu',
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.percent,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tỷ lệ đúng: $percentage%',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Attempts info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  hasRemainingAttempts
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    hasRemainingAttempts
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasRemainingAttempts
                      ? Icons.info_outline
                      : Icons.warning_amber_rounded,
                  color: hasRemainingAttempts ? Colors.blue : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasRemainingAttempts
                        ? 'Bạn còn ${attemptLimit - attemptsUsed} lần làm bài'
                        : 'Bạn đã hết lượt làm bài',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          hasRemainingAttempts
                              ? Colors.blue.shade800
                              : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onClose, child: const Text('Đóng')),
        if (hasRemainingAttempts && onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Làm lại')),
        ElevatedButton(
          onPressed: onViewDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Xem chi tiết'),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
