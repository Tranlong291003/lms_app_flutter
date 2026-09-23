import 'package:flutter/material.dart';

/// Trạng thái rỗng / lỗi dùng chung cho mọi danh sách trong app.
///
/// Trước đây mỗi màn hình tự vẽ một kiểu: có chỗ chỉ `Text('Không có dữ liệu')`
/// lệch trái, có chỗ trả `SizedBox.shrink()` nên người dùng chỉ thấy màn hình
/// trắng và không biết là đang rỗng hay đang lỗi. Widget này gom về một dạng
/// thống nhất: icon + tiêu đề + mô tả + nút hành động (tuỳ chọn).
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  /// `true` thì icon và tiêu đề dùng màu lỗi.
  final bool isError;

  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.isError = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isError ? theme.colorScheme.error : theme.colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: accent.withOpacity(0.8)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.65),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
