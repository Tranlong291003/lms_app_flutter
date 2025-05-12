import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';

class CourseCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String duration;
  final double progressValue;
  final Color progressColor;
  final String progressText;
  final bool showCircular;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.duration,
    required this.progressValue,
    required this.progressColor,
    required this.progressText,
    required this.showCircular,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
              // PHẦN ẢNH
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  '${ApiConfig.baseUrl}$thumbnail',
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
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
                  },
                ),
              ),
              const SizedBox(width: 14),
              // PHẦN TEXT
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
                    if (!showCircular) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          color: progressColor,
                          backgroundColor: theme.dividerColor.withOpacity(0.12),
                          minHeight: 7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        progressText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // PHẦN BIỂU ĐỒ TRÒN TO
              if (showCircular)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 64,
                    width: 64,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 6,
                          color: progressColor,
                          backgroundColor: theme.dividerColor.withOpacity(0.12),
                        ),
                        Text(
                          "${(progressValue * 100).round()}%",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
