import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/screens/course_detail/shared/icon_text.dart';

class CourseStatsSection extends StatelessWidget {
  final String category;
  final double? rating;
  final int reviewCount;
  final int enrollmentCount;
  final String duration;
  const CourseStatsSection({
    super.key,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.enrollmentCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color boxColor =
        theme.colorScheme.surfaceContainerHighest ??
        theme.colorScheme.surface.withOpacity(
          theme.brightness == Brightness.dark ? 0.7 : 0.96,
        );
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
                        color: theme.colorScheme.outline.withOpacity(0.18),
                        width: 1.2,
                      )
                      : null,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withOpacity(0.06),
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
                IconText(
                  icon: Icons.verified,
                  text: 'Có chứng chỉ',
                  iconColor: AppTheme.success,
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

  Widget _chip(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
