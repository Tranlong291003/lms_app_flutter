import 'package:flutter/material.dart';

void showFeatureInDevelopmentMessage(BuildContext context, String feature) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.construction_rounded,
            color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chức năng "$feature" đang được phát triển',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? Colors.grey.shade800 : Colors.amber.shade50,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ),
  );
}
