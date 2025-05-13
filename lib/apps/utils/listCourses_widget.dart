// lib/widgets/list_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/models/courses/courses_model.dart';

class ListCoursesWidget extends StatelessWidget {
  final List<Course> courses;
  const ListCoursesWidget({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceFmt = NumberFormat('#,###');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final c = courses[i];
        final actualPrice = c.discountPrice > 0 ? c.discountPrice : c.price;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.courseDetail,
              arguments: c.courseId,
            );
          },
          child: Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ApiConfig.getImageUrl(c.thumbnailUrl) ?? '',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 120,
                              height: 120,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tags
                          Row(
                            children: [
                              _tag(
                                context,
                                c.categoryName,
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 8),
                              _tag(
                                context,
                                c.level,
                                _getLevelColor(context, c.level),
                                theme.colorScheme.onPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Title
                          Text(
                            c.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                          const SizedBox(height: 6),

                          // Price row
                          Row(
                            children: [
                              Text(
                                "${priceFmt.format(actualPrice)} VND",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              if (c.discountPrice > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "${priceFmt.format(c.price)} VND",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Rating and Enroll count
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                c.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.person,
                                size: 16,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${c.enrollCount} người học',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Bookmark
                Positioned(
                  top: 0,
                  right: 0,
                  child: BookmarkButton(initialSaved: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tag(BuildContext context, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }

  static Color _getLevelColor(BuildContext context, String level) {
    final theme = Theme.of(context);
    switch (level.toLowerCase()) {
      case 'cơ bản':
        return theme.colorScheme.tertiary;
      case 'trung cấp':
        return theme.colorScheme.secondary;
      case 'nâng cao':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}

class BookmarkButton extends StatefulWidget {
  final bool initialSaved;
  final Function(bool)? onChanged;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const BookmarkButton({
    super.key,
    this.initialSaved = false,
    this.onChanged,
    this.size = 32,
    this.color,
    this.backgroundColor,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late bool isSaved;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isSaved = widget.initialSaved;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleBookmark() {
    setState(() {
      isSaved = !isSaved;
      _controller.forward().then((_) => _controller.reverse());
      widget.onChanged?.call(isSaved);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleBookmark,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color:
                  widget.backgroundColor ??
                  theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: widget.color ?? theme.colorScheme.primary,
              size: widget.size * 0.6,
            ),
          ),
        ),
      ),
    );
  }
}
