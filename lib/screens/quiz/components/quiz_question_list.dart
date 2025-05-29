import 'package:flutter/material.dart';

class QuizQuestionList extends StatelessWidget {
  final int totalQuestions;
  final int? selectedQuestionIndex;
  final List<bool> answeredQuestions;
  final int remainingSeconds;
  final int attemptsUsed;
  final int attemptLimit;
  final int answeredCount;
  final Function(int) onQuestionSelected;
  final VoidCallback onSubmit;

  const QuizQuestionList({
    super.key,
    required this.totalQuestions,
    required this.selectedQuestionIndex,
    required this.answeredQuestions,
    required this.remainingSeconds,
    required this.attemptsUsed,
    required this.attemptLimit,
    required this.answeredCount,
    required this.onQuestionSelected,
    required this.onSubmit,
  });

  String _formatRemainingTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(ColorScheme colorScheme) {
    if (remainingSeconds < 60) {
      return colorScheme.error;
    } else if (remainingSeconds < 300) {
      return colorScheme.tertiary;
    } else {
      return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
              border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                // Tiêu đề
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Danh sách câu hỏi',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Hiển thị thời gian và tiến độ
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getTimerColor(colorScheme).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 20,
                              color: _getTimerColor(colorScheme),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatRemainingTime(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getTimerColor(colorScheme),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lần: $attemptsUsed/$attemptLimit',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurface),
                        ),
                      ),
                      Text(
                        'Đã trả lời: $answeredCount/$totalQuestions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),
                const SizedBox(height: 8),

                SizedBox(
                  height: 220,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                    itemCount: totalQuestions,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final isSelected = selectedQuestionIndex == index;
                      final isAnswered = answeredQuestions[index];

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          onQuestionSelected(index);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: _buildQuestionNumber(
                          context: context,
                          index: index,
                          isCurrent: isSelected,
                          isAnswered: isAnswered,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Chú thích
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(
                        context,
                        color: colorScheme.surfaceContainerHighest,
                        label: 'Chưa trả lời',
                        textColor: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      _buildLegend(
                        context,
                        color: colorScheme.secondaryContainer,
                        label: 'Đã trả lời',
                        textColor: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      _buildLegend(
                        context,
                        color: colorScheme.primary,
                        label: 'Câu hiện tại',
                        textColor: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Nút nộp bài
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Nộp bài',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNumber({
    required BuildContext context,
    required int index,
    required bool isCurrent,
    required bool isAnswered,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color textColor;

    if (isCurrent) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isAnswered) {
      bgColor = colorScheme.secondaryContainer;
      textColor = colorScheme.onSecondaryContainer;
    } else {
      bgColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      width: 48,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isCurrent
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.2),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '${index + 1}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    required Color color,
    required String label,
    required Color textColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
