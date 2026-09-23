import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/course_card.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/services/bookmark_service.dart';

class BookmarkScreen extends StatefulWidget {
  final String userUid;
  final String? token;

  const BookmarkScreen({super.key, required this.userUid, this.token});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late BookmarkCubit _bookmarkCubit;
  late CourseCubit _courseCubit;
  bool _isLoading = true;
  List<Course> _bookmarkedCourses = [];
  List<Course> _filteredCourses = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initCubits();
  }

  void _filterCourses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCourses = _bookmarkedCourses;
      } else {
        _filteredCourses =
            _bookmarkedCourses.where((course) {
              final title = course.title.toLowerCase();
              final description = course.description.toLowerCase();
              final searchLower = query.toLowerCase();
              return title.contains(searchLower) ||
                  description.contains(searchLower);
            }).toList();
      }
    });
  }

  Future<void> _initCubits() async {
    if (widget.userUid.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Khởi tạo bookmark service và cubit
    final bookmarkService = BookmarkService(token: widget.token);
    final bookmarkRepository = BookmarkRepository(bookmarkService);
    _bookmarkCubit = BookmarkCubit(bookmarkRepository);

    // Khởi tạo course cubit
    final courseRepository = RepositoryProvider.of<CourseRepository>(context);
    _courseCubit = CourseCubit(courseRepository);

    try {
      // Tải danh sách bookmark
      await _bookmarkCubit.getBookmarks(widget.userUid);
    } catch (_) {
      // Không tải được bookmark thì vẫn hiển thị trạng thái rỗng có nút thử
      // lại, thay vì treo vòng xoay vô hạn.
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    // Danh sách khoá học do `CourseCubit` tự nạp trong constructor và có thể
    // xong SAU khi bookmark tải xong. Trước đây chỗ này `await Future.delayed(
    // 500ms)` rồi đọc `state` một lần: mạng chậm hơn 500ms là danh sách rỗng
    // cho tới khi có sự kiện Cubit không liên quan đẩy vào — người dùng thấy
    // "chưa lưu khoá học nào" dù thực tế có. Giờ ghép lại mỗi khi Cubit đổi.
    _courseCubit.stream.listen((_) {
      if (mounted) _fetchBookmarkedCourses();
    });
    _fetchBookmarkedCourses();
  }

  void _fetchBookmarkedCourses() {
    if (!mounted) return;

    if (_bookmarkCubit.state.bookmarks.isEmpty) {
      setState(() {
        _bookmarkedCourses = [];
        _filteredCourses = [];
      });
      return;
    }

    final allCourses =
        _courseCubit.state is CourseLoaded
            ? (_courseCubit.state as CourseLoaded).courses
            : const <Course>[];

    // Lấy danh sách course ID đã bookmark
    final bookmarkedIds =
        _bookmarkCubit.state.bookmarks
            .map((bookmark) => bookmark.courseId)
            .toSet();

    // Lọc ra các khóa học đã bookmark
    final matched =
        allCourses
            .where((course) => bookmarkedIds.contains(course.courseId))
            .toList();

    // Đánh dấu tất cả là đã bookmark
    for (final course in matched) {
      course.isBookmarked = true;
    }

    setState(() {
      _bookmarkedCourses = matched;
      if (_searchQuery.isEmpty) {
        _filteredCourses = matched;
      } else {
        _filterCourses(_searchQuery);
      }
    });
  }

  @override
  void dispose() {
    _bookmarkCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: "Danh sách khoá học yêu thich",
          showBack: true,
          showSearch: true,
        ),
        body: const Center(child: LoadingIndicator()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _bookmarkCubit),
        BlocProvider.value(value: _courseCubit),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<BookmarkCubit, BookmarkState>(
            listener: (context, state) {
              if (state.status == BookmarkStatus.loaded) {
                _fetchBookmarkedCourses();
                setState(() {});
              }
            },
          ),
          BlocListener<CourseCubit, CourseState>(
            listener: (context, state) {
              if (state is CourseLoaded) {
                _fetchBookmarkedCourses();
                setState(() {});
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Khoá học đã lưu',
            showBack: true,
            showSearch: true,
            onSearchChanged: _filterCourses,
          ),
          body: BlocBuilder<BookmarkCubit, BookmarkState>(
            builder: (context, bookmarkState) {
              if (bookmarkState.status == BookmarkStatus.loading) {
                return const Center(child: LoadingIndicator());
              }

              if (bookmarkState.status == BookmarkStatus.error) {
                return EmptyStateWidget(
                  icon: Icons.cloud_off_rounded,
                  title: 'Không tải được danh sách đã lưu',
                  message: bookmarkState.errorMessage,
                  isError: true,
                  actionLabel: 'Thử lại',
                  onAction: () => _bookmarkCubit.getBookmarks(widget.userUid),
                );
              }

              if (bookmarkState.bookmarks.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Bạn chưa lưu khoá học nào',
                  message:
                      'Nhấn biểu tượng dấu trang trên thẻ khoá học để lưu lại và xem sau.',
                  actionLabel: 'Tìm khoá học',
                  onAction: () {
                    Navigator.pushNamed(context, AppRouter.listCourse);
                  },
                );
              }

              return _buildBookmarkedCoursesList();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await _bookmarkCubit.refreshBookmarks(widget.userUid);
    _courseCubit.refreshCourses();
  }

  Widget _buildBookmarkedCoursesList() {
    // Tìm kiếm không khớp kết quả nào — nói rõ là do từ khoá, khác hẳn với
    // "chưa lưu khoá học nào".
    if (_filteredCourses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'Không tìm thấy khoá học',
        message: 'Không có khoá học nào trong danh sách đã lưu khớp "$_searchQuery".',
        actionLabel: 'Xoá tìm kiếm',
        onAction: () => _filterCourses(''),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        padding: listPaddingWithBottomInset(context),
        itemCount: _filteredCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) {
          final course = _filteredCourses[index];
          // Dùng chung `CourseCard` với trang chủ và màn tìm kiếm: trước đây
          // màn này tự dựng một thẻ riêng, vừa tràn 4px vừa hiển thị nhãn cấp
          // độ bằng bảng màu khác.
          return CourseCard(
            course: course,
            userUid: widget.userUid,
            token: widget.token,
            bookmarkCubit: _bookmarkCubit,
            onUnbookmarked: (c) {
              setState(() {
                _bookmarkedCourses.removeWhere(
                  (item) => item.courseId == c.courseId,
                );
                _filteredCourses.removeWhere(
                  (item) => item.courseId == c.courseId,
                );
              });
            },
          );
        },
      ),
    );
  }


}
