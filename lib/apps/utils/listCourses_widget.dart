// lib/widgets/list_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/bookmark_button.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/services/course_service.dart';
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
    // Luôn khởi tạo `_bookmarkCubit` TRƯỚC mọi nhánh return: `build` dùng nó
    // trong BlocProvider nên nếu bỏ qua sẽ ném LateInitializationError và làm
    // sập cả danh sách khóa học (xảy ra khi người dùng chưa đăng nhập).
    final bookmarkService = BookmarkService(token: widget.token);
    final bookmarkRepository = BookmarkRepository(bookmarkService);
    _bookmarkCubit = BookmarkCubit(bookmarkRepository);

    if (widget.userUid.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      await _bookmarkCubit.getBookmarks(widget.userUid);

      _updateCoursesBookmarkStatus();
    } catch (_) {
      // Không tải được bookmark thì danh sách khóa học vẫn phải hiển thị:
      // trạng thái lưu sẽ chỉ ở mức mặc định (chưa lưu).
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

          // Trước đây trả `SizedBox.shrink()` → người dùng chỉ thấy màn hình
          // trắng, không phân biệt được "đang rỗng" với "đang lỗi".
          if (coursesToDisplay.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.menu_book_outlined,
              title: 'Chưa có khoá học nào',
              message: 'Các khoá học mới sẽ xuất hiện ở đây.',
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: coursesToDisplay.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final c = coursesToDisplay[i];

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
                  // Dùng ràng buộc chiều cao tối thiểu thay vì `height` cố định:
                  // card cũ cao đúng 140px trong khi ảnh đã 120px + padding 24px
                  // → tràn 4px; và khi người dùng tăng cỡ chữ hệ thống thì phần
                  // chữ bên phải còn tràn nhiều hơn.
                  constraints: const BoxConstraints(minHeight: 144),
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
                                      width: _thumbSize(context),
                                      height: _thumbSize(context),
                                      fit: BoxFit.cover,
                                      loadingBuilder: (_, child, progress) {
                                        if (progress == null) return child;
                                        return _buildPlaceholderImage(context);
                                      },
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
                                // Tags.
                                //
                                // Cả hai tag phải co giãn được: tên danh mục
                                // dài ("Lập trình Web") cộng với tag cấp độ
                                // vượt quá bề rộng còn lại của thẻ trên máy nhỏ
                                // → tràn 131px (đã bắt được bằng test bố cục).
                                Row(
                                  children: [
                                    Flexible(
                                      child: _tag(
                                        context,
                                        c.categoryName,
                                        theme.colorScheme.primaryContainer,
                                        theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: _tag(
                                        context,
                                        courseLevelLabel(c.level),
                                        _getLevelColor(context, c.level),
                                        theme.colorScheme.onPrimary,
                                      ),
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
                                  maxLines: 2,
                                  // `clip` cắt ngang giữa chữ mà không có dấu
                                  // "..." nên người dùng không biết tên bị cụt.
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),

                                // Price row
                                Row(
                                  children: [
                                    // Giá bán cũng phải co giãn: ở chữ lớn (x1.3)
                                    // trên máy 320px, giá bán + giá gốc vượt bề
                                    // rộng còn lại nên tràn 40px.
                                    Flexible(
                                      child: Text(
                                        c.displayPrice,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                    ),
                                    if (c.discountPrice > 0 && c.price > 0) ...[
                                      const SizedBox(width: 8),
                                      // `Flexible` để giá gạch ngang thu nhỏ chứ
                                      // không đẩy tràn cả hàng khi giá dài.
                                      Flexible(
                                        child: Text(
                                          '${_formatVnd(c.price)} đ',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.6),
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Rating and Enroll count.
                                //
                                // Bọc `Flexible` cho cả điểm đánh giá: số điểm
                                // dài (vd "4.3") cộng hai icon và khoảng cách
                                // vẫn có thể vượt bề rộng thẻ trên máy rất nhỏ.
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        c.rating.toStringAsFixed(1),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${c.enrollCount} người học',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
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

  /// Định dạng tiền theo kiểu Việt Nam (phân cách nghìn bằng dấu chấm).
  ///
  /// Trước đây giá gốc gạch ngang dùng `NumberFormat('#,###')` cho ra
  /// "1,299,000 VND" trong khi giá bán dùng dấu chấm — hai định dạng khác nhau
  /// nằm cạnh nhau trên cùng một thẻ.
  static String _formatVnd(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );

  /// Kích thước ảnh thu nhỏ của thẻ.
  ///
  /// Cố định 120px từng khiến cột chữ chỉ còn ~132px trên máy 320px, không đủ
  /// cho hàng tag + giá + đánh giá → tràn. Thu nhỏ ảnh trên màn hẹp để nhường
  /// chỗ cho phần chữ.
  double _thumbSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 88;
    if (width < 400) return 104;
    return 120;
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final size = _thumbSize(context);
    return Container(
      width: size,
      height: size,
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
        // Tag bị co lại (Flexible ở hàng tags) phải cắt bằng "..." thay vì
        // tràn chữ ra ngoài khung.
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }

  static Color _getLevelColor(BuildContext context, String level) {
    final theme = Theme.of(context);
    // API trả `level` dạng beginner | intermediate | advanced; vẫn nhận thêm
    // nhãn tiếng Việt để tương thích dữ liệu cũ.
    switch (normalizeCourseLevel(level)) {
      case 'beginner':
        return theme.colorScheme.tertiary;
      case 'intermediate':
        return theme.colorScheme.secondary;
      case 'advanced':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}
