import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';

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
    final scheme = theme.colorScheme;

    // Dùng cặp "container" của Material thay vì tự pha màu bằng opacity: cặp
    // này đã được thiết kế để chữ/icon nằm trên đó luôn đủ tương phản ở cả hai
    // chế độ sáng/tối.
    final bg = isError ? scheme.errorContainer : scheme.primaryContainer;
    final fg = isError ? scheme.onErrorContainer : scheme.onPrimaryContainer;

    return Center(
      child: SingleChildScrollView(
        // Trạng thái rỗng xuất hiện trong nhiều ngữ cảnh, kể cả trong ô thấp
        // (tab, khối con). Nếu không cho cuộn thì ở cỡ chữ lớn nội dung sẽ tràn.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxxl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, size: 42, color: fg),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
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

/// Đệm cho `ListView` trong màn hình cuộn được.
///
/// `EdgeInsets.all(16)` không tính tới vùng an toàn dưới đáy, nên mục cuối cùng
/// có thể nằm dưới thanh home indicator và khó chạm. Hàm này trả về đệm 16px
/// như cũ, nhưng cộng thêm phần đáy bị hệ thống chiếm (nếu có).
EdgeInsets listPaddingWithBottomInset(BuildContext context, {double all = 16}) {
  final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
  return EdgeInsets.fromLTRB(all, all, all, all + bottomInset);
}
