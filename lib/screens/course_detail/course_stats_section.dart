import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/course_card.dart' show formatVnd;
import 'package:lms/screens/course_detail/shared/icon_text.dart';

class CourseStatsSection extends StatelessWidget {
  final String category;
  final double? rating;
  final int reviewCount;
  final int enrollmentCount;
  final String duration;

  /// Giá gốc và giá khuyến mãi (`GET /api/courses/:course_id` trả cả hai).
  /// Trước đây màn chi tiết không hiển thị giá nên người dùng không biết khoá
  /// học có phí trước khi bấm đăng ký.
  final int price;
  final int discountPrice;

  const CourseStatsSection({
    super.key,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.enrollmentCount,
    required this.duration,
    required this.price,
    required this.discountPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // `surfaceContainerHighest` không bao giờ null (ColorScheme có giá trị mặc
    // định), nên nhánh dự phòng cũ là code chết.
    final Color boxColor = theme.colorScheme.surfaceContainerHighest;
    final bool isLight = theme.brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _chip(context, category),
            const SizedBox(width: 12),
            _starRating(theme),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(14),
              border:
                  isLight
                      ? Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.18),
                        width: 1.2,
                      )
                      : null,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 22,
              runSpacing: 16,
              children: [
                IconText(
                  icon: Icons.people,
                  text: '$enrollmentCount học viên',
                  iconColor: theme.colorScheme.primary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconText(
                  icon: Icons.timer,
                  text: duration,
                  iconColor: theme.colorScheme.secondary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Trước đây chỗ này là "Có chứng chỉ" — một lời hứa cứng, vì
                // API không có endpoint/bảng nào cấp chứng chỉ. Thay bằng giá
                // thật lấy từ `price`/`discount_price`, thứ người học cần biết
                // trước khi bấm đăng ký.
                IconText(
                  icon: isFree ? Icons.lock_open_rounded : Icons.sell_outlined,
                  text: _priceLabel(),
                  iconColor:
                      isFree
                          ? AppColors.of(context).success
                          : theme.colorScheme.secondary,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Khoá học miễn phí khi giá gốc bằng 0.
  bool get isFree => price <= 0;

  /// Giá hiển thị: dùng giá khuyến mãi nếu có, kèm giá gốc gạch ngang.
  String _priceLabel() {
    if (isFree) return 'Miễn phí';
    final effective = discountPrice > 0 ? discountPrice : price;
    if (discountPrice > 0 && price > discountPrice) {
      return '${formatVnd(effective)} đ (${formatVnd(price)} đ)';
    }
    return '${formatVnd(effective)} đ';
  }

  Widget _chip(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  Widget _starRating(ThemeData theme) => Row(
    children: [
      Icon(Icons.star_rounded, size: 20, color: theme.colorScheme.secondary),
      const SizedBox(width: 4),
      Text(
        rating != null
            ? '${rating!.toStringAsFixed(1)} ($reviewCount đánh giá)'
            : 'Chưa có đánh giá',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
