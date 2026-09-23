import 'package:flutter/material.dart';

import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_theme.dart';

/// Sắc thái của một trạng thái hiển thị.
enum StatusTone {
  /// Đã duyệt, đang hoạt động, thành công.
  success,

  /// Chờ xử lý, sắp hết hạn, cần chú ý.
  warning,

  /// Bị từ chối, bị khoá, thất bại.
  error,

  /// Thông tin trung tính có nhấn mạnh (đang tiến hành…).
  info,

  /// Không xác định / đã kết thúc.
  neutral,
}

/// Nhãn trạng thái dạng viên — dùng chung cho mọi danh sách có trạng thái.
///
/// Trước đây mỗi màn hình tự ghép `Colors.green` / `Colors.red` /
/// `Colors.orange` với nền `Colors.green.shade50`:
///  - `Colors.green` trên nền tối chỉ đạt ~2.6:1, gần như không đọc được;
///  - ba tông đó không nằm trong bảng màu của app nên nhìn lệch hẳn;
///  - cùng một trạng thái "Chờ duyệt" lại ra màu khác nhau ở mỗi màn hình.
///
/// Widget này lấy màu từ [AppSemanticColors] nên tự đúng ở cả sáng và tối.
class StatusChip extends StatelessWidget {
  final String label;
  final StatusTone tone;

  /// Hiện chấm tròn nhỏ trước nhãn (giúp phân biệt cả khi in đen trắng).
  final bool showDot;

  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusTone.neutral,
    this.showDot = true,
    this.icon,
  });

  /// Suy ra sắc thái từ chuỗi trạng thái thường gặp của API.
  ///
  /// Nhận cả tiếng Anh (`approved`) và tiếng Việt (`Đã duyệt`) vì dữ liệu cũ
  /// trong hệ thống có cả hai.
  static StatusTone toneFor(String? status) {
    switch ((status ?? '').trim().toLowerCase()) {
      case 'approved':
      case 'active':
      case 'completed':
      case 'success':
      case 'published':
      case 'đã duyệt':
      case 'hoạt động':
      case 'đã hoàn thành':
        return StatusTone.success;
      case 'pending':
      case 'processing':
      case 'in_progress':
      case 'draft':
      case 'chờ duyệt':
      case 'đang xử lý':
      case 'đang học':
        return StatusTone.warning;
      case 'rejected':
      case 'blocked':
      case 'inactive':
      case 'banned':
      case 'failed':
      case 'từ chối':
      case 'bị khoá':
      case 'đã khoá':
        return StatusTone.error;
      case 'info':
      case 'reviewing':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = AppColors.of(context);

    final (Color bg, Color fg) = switch (tone) {
      StatusTone.success => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
      ),
      StatusTone.warning => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      StatusTone.error => (scheme.errorContainer, scheme.onErrorContainer),
      StatusTone.info => (
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
      ),
      StatusTone.neutral => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    // Chấm tròn dùng màu ngữ nghĩa đậm hơn để phân biệt trạng thái rõ hơn cả
    // khi nền các chip gần giống nhau.
    final Color dotColor = switch (tone) {
      StatusTone.success => semantic.success,
      StatusTone.warning => semantic.warning,
      StatusTone.error => semantic.error,
      StatusTone.info => semantic.info,
      StatusTone.neutral => scheme.onSurfaceVariant,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: fg)
          else if (showDot)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          if (icon != null || showDot) const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
