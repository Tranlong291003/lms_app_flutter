import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';

class CourseCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String duration;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.duration,
    required this.completedLessons,
    required this.totalLessons,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final double percent =
        (totalLessons > 0)
            ? (completedLessons / totalLessons).clamp(0.0, 1.0)
            : 0.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.black.withOpacity(0.03)
                        : theme.shadowColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color:
                  isDark
                      ? theme.dividerColor.withOpacity(0.12)
                      : theme.dividerColor.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    thumbnail.isNotEmpty
                        ? Image.network(
                          ApiConfig.getImageUrl(thumbnail),
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(context, theme);
                          },
                        )
                        : _buildPlaceholderImage(context, theme),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      duration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: theme.dividerColor.withOpacity(0.12),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$completedLessons/$totalLessons bài học',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, ThemeData theme) {
    return Container(
      height: 64,
      width: 64,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        color: theme.colorScheme.onSurface.withOpacity(0.25),
        size: 32,
      ),
    );
  }
}
