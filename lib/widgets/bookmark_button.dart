import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      print('userUid trống, không thể tải bookmark');
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
      } catch (e) {
        print('Lỗi khi tải bookmark: $e');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _checkBookmarkStatus() {
    if (_bookmarkCubit != null) {
      final wasBookmarked = _isBookmarked;
      _isBookmarked = _bookmarkCubit!.isBookmarked(widget.courseId);
      _bookmark = _bookmarkCubit!.getBookmarkByCourseId(widget.courseId);

      print(
        'Trạng thái bookmark của khóa học ${widget.courseId}: $_isBookmarked',
      );
      if (wasBookmarked != _isBookmarked) {
        print(
          'Trạng thái bookmark đã thay đổi từ $wasBookmarked thành $_isBookmarked',
        );
      }
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
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_bookmarkCubit == null) {
      return Icon(
        Icons.bookmark_border_rounded,
        size: widget.size,
        color:
            widget.inactiveColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                                Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5)),
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

        if (success) {
          print('Đã xóa bookmark thành công');
        } else {
          print('Không thể xóa bookmark');
        }

        // Refresh danh sách bookmark
        await _bookmarkCubit!.refreshBookmarks(widget.userUid);
      } else {
        // Thêm bookmark mới
        try {
          final newBookmark = await _bookmarkCubit!.createBookmark(
            courseId: widget.courseId,
            userUid: widget.userUid,
          );

          print('Bookmark đã được tạo thành công: ${newBookmark.id}');
          success = true;

          // Refresh danh sách bookmark
          await _bookmarkCubit!.refreshBookmarks(widget.userUid);
        } catch (e) {
          print('Lỗi khi tạo bookmark: $e');
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

      // Hiển thị thông báo nếu có lỗi
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Có lỗi xảy ra khi cập nhật bookmark'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Lỗi khi thay đổi trạng thái bookmark: $e');
      // Hiển thị thông báo lỗi cho người dùng nếu cần
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật bookmark: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
