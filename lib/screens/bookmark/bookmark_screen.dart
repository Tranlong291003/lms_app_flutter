import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/services/bookmark_service.dart';
import 'package:lms/apps/utils/bookmark_button.dart';

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
      print('userUid trống, không thể tải bookmark');
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

      // Đợi cho course cubit tải xong dữ liệu
      await Future.delayed(const Duration(milliseconds: 500));

      // Lấy thông tin chi tiết các khóa học đã bookmark
      _fetchBookmarkedCourses();
    } catch (e) {
      print('Lỗi khi khởi tạo cubits: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _fetchBookmarkedCourses() {
    if (_bookmarkCubit.state.bookmarks.isEmpty) {
      _bookmarkedCourses = [];
      _filteredCourses = [];
      return;
    }

    if (_courseCubit.state is CourseLoaded) {
      final allCourses = (_courseCubit.state as CourseLoaded).courses;

      // Lấy danh sách course ID đã bookmark
      final bookmarkedIds =
          _bookmarkCubit.state.bookmarks
              .map((bookmark) => bookmark.courseId)
              .toList();

      // Lọc ra các khóa học đã bookmark
      _bookmarkedCourses =
          allCourses
              .where((course) => bookmarkedIds.contains(course.courseId))
              .toList();

      // Đánh dấu tất cả là đã bookmark
      for (var course in _bookmarkedCourses) {
        course.isBookmarked = true;
      }

      // Khởi tạo danh sách đã lọc
      _filteredCourses = _bookmarkedCourses;

      print('Tìm thấy ${_bookmarkedCourses.length} khóa học đã bookmark');
    }
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
            title: "Danh sách khoá học yêu thich",
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã xảy ra lỗi: ${bookmarkState.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            () => _bookmarkCubit.getBookmarks(widget.userUid),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (bookmarkState.bookmarks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa lưu khóa học nào',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.listCourse);
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Tìm khóa học'),
                      ),
                    ],
                  ),
                );
              }

              return _buildBookmarkedCoursesList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarkedCoursesList() {
    final priceFmt = NumberFormat('#,###');

    if (_filteredCourses.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await _bookmarkCubit.refreshBookmarks(widget.userUid);
          _courseCubit.refreshCourses();
        },
        child: ListView.builder(
          itemCount: _bookmarkCubit.state.bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = _bookmarkCubit.state.bookmarks[index];
            return _buildSimpleBookmarkItem(bookmark);
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _bookmarkCubit.refreshBookmarks(widget.userUid);
        _courseCubit.refreshCourses();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCourses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final course = _filteredCourses[index];
          final bookmark = _bookmarkCubit.getBookmarkByCourseId(
            course.courseId,
          );
          return _buildBookmarkItem(course, bookmark);
        },
      ),
    );
  }

  Widget _buildSimpleBookmarkItem(BookmarkModel bookmark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          Icons.bookmark,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text('Khóa học ID: ${bookmark.courseId}'),
        subtitle: Text(
          'Đã lưu vào: ${bookmark.createdAt.day}/${bookmark.createdAt.month}/${bookmark.createdAt.year}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteConfirmation(bookmark),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.courseDetail,
            arguments: bookmark.courseId,
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BookmarkModel bookmark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xóa Bookmark'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa bookmark này không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _bookmarkCubit.deleteBookmark(
        bookmarkId: bookmark.id,
        userUid: widget.userUid,
      );

      setState(() {
        _bookmarkedCourses.removeWhere(
          (course) => course.courseId == bookmark.courseId,
        );
      });
    }
  }

  Widget _buildBookmarkItem(Course course, BookmarkModel? bookmark) {
    final priceFmt = NumberFormat('#,###');
    final actualPrice =
        course.discountPrice > 0 ? course.discountPrice : course.price;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.courseDetail,
          arguments: course.courseId,
        );
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
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
                      course.thumbnailUrl != null &&
                              course.thumbnailUrl!.isNotEmpty
                          ? Image.network(
                            ApiConfig.getImageUrl(course.thumbnailUrl),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => _buildPlaceholderImage(context),
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
                            course.categoryName,
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          _tag(
                            context,
                            course.level,
                            _getLevelColor(context, course.level),
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        course.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Price
                      Row(
                        children: [
                          Text(
                            course.displayPrice,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          if (course.discountPrice > 0 && course.price > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              course.price == 0
                                  ? ''
                                  : '${course.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} VND',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Rating & Enroll
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.enrollCount} người học',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bookmark button
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: BookmarkButton(
                      courseId: course.courseId,
                      userUid: widget.userUid,
                      token: widget.token,
                      size: 20,
                      bookmarkCubit: _bookmarkCubit,
                      onToggle: (isBookmarked) {
                        if (!isBookmarked) {
                          setState(() {
                            _bookmarkedCourses.removeWhere(
                              (c) => c.courseId == course.courseId,
                            );
                            _filteredCourses.removeWhere(
                              (c) => c.courseId == course.courseId,
                            );
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _tag(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getLevelColor(BuildContext context, String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
