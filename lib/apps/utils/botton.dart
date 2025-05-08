import 'package:flutter/material.dart';

// Hàm tạo ElevatedButton với text tùy chỉnh và hành động onPressed tùy chỉnh
ElevatedButton botton({
  required BuildContext context,
  required String text,
  required VoidCallback onPressed,
  double? width,
  double height = 50,
}) {
  final theme = Theme.of(context);

  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      minimumSize: Size(width ?? double.infinity, height),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ),
    child: Text(text),
  );
}
