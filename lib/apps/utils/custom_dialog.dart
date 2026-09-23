import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? cancelText;
  final String confirmText;
  final Color? confirmColor;
  final IconData? icon;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText,
    required this.confirmText,
    this.confirmColor,
    this.icon,
    this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      // Dáng hộp thoại lấy từ `dialogTheme` để mọi hộp thoại trong app đồng
      // nhất; chỉ ghi đè những gì riêng của widget này.
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: confirmColor ?? theme.colorScheme.primary),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(content, style: theme.textTheme.bodyLarge),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text(cancelText!),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? theme.colorScheme.primary,
            // `Colors.white` cố định sẽ mất tương phản khi `confirmColor` là
            // màu sáng (ví dụ `tertiary`); suy ra màu chữ từ chính nền đó.
            foregroundColor:
                ThemeData.estimateBrightnessForColor(
                          confirmColor ?? theme.colorScheme.primary,
                        ) ==
                        Brightness.dark
                    ? Colors.white
                    : Colors.black87,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Extension để dễ dàng hiển thị dialog
extension CustomDialogExtension on BuildContext {
  Future<bool?> showCustomDialog({
    required String title,
    required String content,
    String? cancelText,
    required String confirmText,
    Color? confirmColor,
    IconData? icon,
    VoidCallback? onCancel,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: this,
      builder:
          (context) => CustomDialog(
            title: title,
            content: content,
            cancelText: cancelText,
            confirmText: confirmText,
            confirmColor: confirmColor,
            icon: icon,
            onCancel: onCancel,
            onConfirm: onConfirm,
          ),
    );
  }
}
