import 'package:flutter/material.dart';

import 'package:lms/apps/config/app_dimens.dart';

/// Một ô số liệu trên dashboard.
class StatItem {
  final String title;
  final String value;
  final IconData icon;

  /// Màu nhấn của ô — nên lấy từ `AppColors.of(context)`.
  final Color color;

  const StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

/// Lưới số liệu dùng chung cho dashboard admin và mentor.
///
/// ## Vì sao không dùng `GridView` với chiều cao cố định
///
/// Cách cũ dùng `childAspectRatio: 1.2`: trên máy 320px ô chỉ cao ~115px trong
/// khi nội dung cần hơn 200px ở cỡ chữ lớn — tràn hẳn ra ngoài.
///
/// Cách "sửa" bằng công thức (`fontSize × hệ số`) cũng sai: nó lệch vài px vì
/// chiều cao dòng thực tế phụ thuộc font và `height` của `TextStyle`.
///
/// Ở đây không có con số chiều cao nào để đoán: mỗi hàng là một `Row` với
/// `IntrinsicHeight`, nên chiều cao do chính nội dung quyết định.
class StatGrid extends StatelessWidget {
  final List<StatItem> stats;

  /// Số ô trên một hàng.
  final int columns;

  const StatGrid({super.key, required this.stats, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    // Chia thành các hàng, mỗi hàng tối đa [columns] ô.
    final rows = <List<StatItem>>[];
    for (var i = 0; i < stats.length; i += columns) {
      rows.add(stats.sublist(i, (i + columns).clamp(0, stats.length)));
    }

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: AppSpacing.md),
          // `IntrinsicHeight` cho các ô trong cùng hàng cao bằng nhau (ô có
          // nhãn 2 dòng không bị thấp hơn ô có nhãn 1 dòng), còn chiều cao
          // của hàng do NỘI DUNG quyết định — không có con số đoán trước nào
          // để lệch.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(child: _StatTile(stat: rows[r][c])),
                ],
                // Hàng cuối thiếu ô thì chèn khoảng trống để các ô không giãn
                // ra chiếm hết bề rộng.
                for (var c = rows[r].length; c < columns; c++) ...[
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(child: SizedBox.shrink()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Một ô số liệu.
class _StatTile extends StatelessWidget {
  final StatItem stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerHighest : scheme.surface,
        borderRadius: AppRadius.borderLg,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: isDark ? 0.22 : 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            stat.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: stat.color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            stat.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
