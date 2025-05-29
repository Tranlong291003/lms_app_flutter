// lib/widgets/list_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/bookmark_button.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/services/bookmark_service.dart';

class ListCoursesWidget extends StatefulWidget {
  final List<Course> courses;
  final String userUid;
  final String? token;
  final BookmarkCubit? bookmarkCubit;

  const ListCoursesWidget({
    super.key,
    required this.courses,
    required this.userUid,
    this.token,
    this.bookmarkCubit,
  });

  @override
  State<ListCoursesWidget> createState() => _ListCoursesWidgetState();
}

class _ListCoursesWidgetState extends State<ListCoursesWidget> {
  late BookmarkCubit _bookmarkCubit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.bookmarkCubit != null) {
      _bookmarkCubit = widget.bookmarkCubit!;
      _updateCoursesBookmarkStatus();
      _isLoading = false;
    } else {
      _initBookmarks();
    }
  }

  Future<void> _initBookmarks() async {
    if (widget.userUid.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final bookmarkService = BookmarkService(token: widget.token);
    final bookmarkRepository = BookmarkRepository(bookmarkService);
    _bookmarkCubit = BookmarkCubit(bookmarkRepository);

    try {
      await _bookmarkCubit.getBookmarks(widget.userUid);

      _updateCoursesBookmarkStatus();
    } catch (e) {
      print('Không thể tải bookmarks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateCoursesBookmarkStatus() {
    if (widget.courses.isEmpty ||
        _bookmarkCubit.state.status != BookmarkStatus.loaded) {
      return;
    }

    bool hasChanges = false;

    for (int i = 0; i < widget.courses.length; i++) {
      final course = widget.courses[i];
      final isBookmarked = _bookmarkCubit.isBookmarked(course.courseId);
      if (course.isBookmarked != isBookmarked) {
        widget.courses[i].isBookmarked = isBookmarked;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      setState(() {});
    }

    print('Cập nhật trạng thái bookmark cho ${widget.courses.length} khóa học');
  }

  @override
  void dispose() {
    if (widget.bookmarkCubit == null) {
      _bookmarkCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingIndicator());
    }

    final theme = Theme.of(context);
    final priceFmt = NumberFormat('#,###');

    return BlocProvider.value(
      value: widget.bookmarkCubit ?? _bookmarkCubit,
      child: BlocConsumer<BookmarkCubit, BookmarkState>(
        listener: (context, state) {
          if (!state.isBookmarking &&
              !state.isDeleting &&
              state.status == BookmarkStatus.loaded) {
            _updateCoursesBookmarkStatus();
          }
        },
        builder: (context, bookmarkState) {
          if (bookmarkState.status == BookmarkStatus.loading &&
              widget.bookmarkCubit == null) {
            return const Center(child: LoadingIndicator());
          }

          final List<Course> coursesToDisplay = widget.courses;

          if (coursesToDisplay.isEmpty) {
            return const SizedBox.shrink();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coursesToDisplay.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final c = coursesToDisplay[i];
              final actualPrice =
                  c.discountPrice > 0 ? c.discountPrice : c.price;

              final bool isBookmarked = _bookmarkCubit.isBookmarked(c.courseId);

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
                            child:
                                c.thumbnailUrl != null &&
                                        c.thumbnailUrl!.isNotEmpty
                                    ? Image.network(
                                      ApiConfig.getImageUrl(c.thumbnailUrl) ??
                                          '',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              _buildPlaceholderImage(context),
                                    )
                                    : _buildPlaceholderImage(context),
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
                                      c.displayPrice,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                    if (c.discountPrice > 0 && c.price > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        c.price == 0
                                            ? ''
                                            : '${c.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                              decoration:
                                                  TextDecoration.lineThrough,
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
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
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
                      // Bookmark Button
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: BookmarkButton(
                            courseId: c.courseId,
                            userUid: widget.userUid,
                            token: widget.token,
                            size: 20,
                            bookmarkCubit: _bookmarkCubit,
                            onToggle: (isBookmarked) {
                              // Không cần setState ở đây nữa nếu logic cập nhật nằm ở BookmarkCubit
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
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
