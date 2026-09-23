import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/services/bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  final int courseId;
  final String userUid;
  final String? token;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final BookmarkCubit? bookmarkCubit;
  final Function(bool)? onToggle;

  const BookmarkButton({
    super.key,
    required this.courseId,
    required this.userUid,
    this.token,
    this.activeColor,
    this.inactiveColor,
    this.size = 24.0,
    this.bookmarkCubit,
    this.onToggle,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  BookmarkCubit? _bookmarkCubit;
  bool _isLoading = true;
  bool _isBookmarked = false;
  bool _isProcessing = false;
  BookmarkModel? _bookmark;

  // Thêm controller cho animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animation cho scale
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 30),
    ]).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initState();
  }

  Future<void> _initState() async {
    if (widget.bookmarkCubit != null) {
      _bookmarkCubit = widget.bookmarkCubit;
      _checkBookmarkStatus();
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (widget.userUid.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Khởi tạo cubit nếu chưa có
    if (_bookmarkCubit == null) {
      final bookmarkService = BookmarkService(token: widget.token);
      final bookmarkRepository = BookmarkRepository(bookmarkService);
      _bookmarkCubit = BookmarkCubit(bookmarkRepository);
      try {
        await _bookmarkCubit!.getBookmarks(widget.userUid);
        _checkBookmarkStatus();
      } catch (_) {
        // Không tải được danh sách bookmark thì nút vẫn phải hiển thị ở trạng
        // thái "chưa lưu" thay vì treo vòng xoay.
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _checkBookmarkStatus() {
    if (_bookmarkCubit != null) {
      _isBookmarked = _bookmarkCubit!.isBookmarked(widget.courseId);
      _bookmark = _bookmarkCubit!.getBookmarkByCourseId(widget.courseId);
    }
  }

  @override
  void dispose() {
    // Đóng cubit nếu nó được tạo trong widget này
    if (widget.bookmarkCubit == null && _bookmarkCubit != null) {
      _bookmarkCubit!.close();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        // `plain` để không vẽ nền + đổ bóng — ô chỉ rộng bằng `size`.
        child: const LoadingIndicator(plain: true),
      );
    }

    if (_bookmarkCubit == null) {
      return Icon(
        Icons.bookmark_border_rounded,
        size: widget.size,
        color:
            widget.inactiveColor ??
            Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }

    return BlocProvider.value(
      value: _bookmarkCubit!,
      child: BlocConsumer<BookmarkCubit, BookmarkState>(
        listener: (context, state) {
          if (state.isBookmarking || state.isDeleting) {
            setState(() {
              _isProcessing = true;
            });
          } else {
            setState(() {
              _isProcessing = false;
            });

            // Cập nhật trạng thái bookmark sau khi xử lý xong
            if (!state.isBookmarking && !state.isDeleting) {
              _checkBookmarkStatus();

              // Thông báo trạng thái đã thay đổi
              if (widget.onToggle != null) {
                widget.onToggle!(_isBookmarked);
              }
            }
          }
        },
        builder: (context, state) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: IconButton(
                  constraints: BoxConstraints(
                    minWidth: widget.size,
                    minHeight: widget.size,
                  ),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: widget.size,
                    color:
                        _isBookmarked
                            ? (widget.activeColor ??
                                Theme.of(context).colorScheme.primary)
                            : (widget.inactiveColor ??
                                Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  onPressed: _isProcessing ? null : _toggleBookmark,
                  tooltip: _isBookmarked ? 'Bỏ lưu khóa học' : 'Lưu khóa học',
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    try {
      // Chạy animation khi bắt đầu chuyển đổi
      _animationController.reset();
      _animationController.forward();

      setState(() {
        _isProcessing = true;
      });

      bool success = false;

      if (_isBookmarked && _bookmark != null) {
        // Xóa bookmark
        success = await _bookmarkCubit!.deleteBookmark(
          bookmarkId: _bookmark!.id,
          userUid: widget.userUid,
        );

        // Refresh danh sách bookmark
        await _bookmarkCubit!.refreshBookmarks(widget.userUid);
      } else {
        // Thêm bookmark mới
        try {
          await _bookmarkCubit!.createBookmark(
            courseId: widget.courseId,
            userUid: widget.userUid,
          );
          success = true;

          // Refresh danh sách bookmark
          await _bookmarkCubit!.refreshBookmarks(widget.userUid);
        } catch (_) {
          success = false;
        }
      }

      // Cập nhật trạng thái bookmark
      setState(() {
        _checkBookmarkStatus();
        _isProcessing = false;
      });

      if (widget.onToggle != null) {
        widget.onToggle!(_isBookmarked);
      }

      // Chỉ báo khi THẤT BẠI. Thành công đã có phản hồi trực quan ngay trên
      // nút (icon đổi màu + hiệu ứng nhún), thêm snackbar nữa sẽ thành nhiễu.
      if (!success && mounted) {
        CustomSnackBar.showError(
          context: context,
          // Nói rõ việc gì thất bại — thông báo cũ "Có lỗi xảy ra" không cho
          // người dùng biết khoá học vừa rồi có được lưu hay không.
          message: _isBookmarked
              ? 'Không bỏ lưu được khoá học. Vui lòng thử lại.'
              : 'Không lưu được khoá học. Vui lòng thử lại.',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        CustomSnackBar.showError(
          context: context,
          message: 'Không cập nhật được trạng thái lưu. Vui lòng thử lại.',
        );
      }
    }
  }
}
