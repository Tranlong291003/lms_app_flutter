import 'package:flutter/material.dart';

class LessonsTab extends StatelessWidget {
  const LessonsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessons = List.generate(
      6,
      (index) => {
        'title': 'Bài ${index + 1}: Thiết kế giao diện Flutter',
        'duration': '${10 + index * 5} phút',
        'completed': index < 3,
      },
    );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final isCompleted = lesson['completed'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.lock_outline,
                  color:
                      isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson['title']! as String,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson['duration']! as String,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
