import 'package:flutter/material.dart';

class QuizTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const QuizTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Lấy danh sách quiz từ khóa học, nếu không có thì sử dụng mảng rỗng
    final quizList = course['quizList'] as List<dynamic>? ?? [];

    if (quizList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 56,
              color: colors.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài kiểm tra nào',
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Các bài kiểm tra sẽ sớm được cập nhật',
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: quizList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final quiz = quizList[index];
        return _QuizCard(
          title: quiz['title'] ?? 'Bài kiểm tra không tên',
          type: quiz['type'] ?? 'Không xác định',
          timeLimit: quiz['time_limit'] ?? 0,
          passingScore: quiz['passing_score'] ?? 0,
          questionCount: (quiz['questions'] as List<dynamic>?)?.length ?? 0,
        );
      },
    );
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final String type;
  final int timeLimit;
  final int passingScore;
  final int questionCount;

  const _QuizCard({
    required this.title,
    required this.type,
    required this.timeLimit,
    required this.passingScore,
    required this.questionCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section with quiz type badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$questionCount câu hỏi · Điểm đạt: $passingScore%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quiz type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: colors.outlineVariant.withOpacity(0.2)),

          // Quiz info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _QuizInfoItem(
                  icon: Icons.timer,
                  label: 'Thời gian',
                  value: '$timeLimit phút',
                  color: colors.primary,
                ),
                const SizedBox(width: 16),
                _QuizInfoItem(
                  icon: Icons.help_outline,
                  label: 'Số câu hỏi',
                  value: '$questionCount câu',
                  color: colors.secondary,
                ),
                const SizedBox(width: 16),
                _QuizInfoItem(
                  icon: Icons.check_circle_outline,
                  label: 'Điểm đạt',
                  value: '$passingScore%',
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () {},
                child: const Text('Xem chi tiết'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuizInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
