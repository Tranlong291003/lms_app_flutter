// lib/widgets/list_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/course_card.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
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
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, i) {
              final c = coursesToDisplay[i];
              // Dùng chung `CourseCard` với màn "đã lưu": trước đây hai nơi
              // dựng hai thẻ gần giống nhau nhưng khác bảng màu và khác cả
              // cách xử lý chiều cao.
              return CourseCard(
                course: c,
                userUid: widget.userUid,
                token: widget.token,
                bookmarkCubit: _bookmarkCubit,
              );
            },
          );
        },
      ),
    );
  }
}
