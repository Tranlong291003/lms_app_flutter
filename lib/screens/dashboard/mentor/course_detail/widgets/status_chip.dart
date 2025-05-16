import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final Map<String, dynamic> course;

  const StatusChip({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = course['status'] == true || course['status'] == 'true';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isActive
                ? colorScheme.primaryContainer
                : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Đang hoạt động' : 'Đã khoá',
        style: TextStyle(
          color:
              isActive
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onErrorContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
