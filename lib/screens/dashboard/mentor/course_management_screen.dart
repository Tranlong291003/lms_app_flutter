import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/widgets/custom_snackbar.dart';

import 'course_detail/course_detail_screen.dart';
import 'course_form_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Course> _approvedCourses = [];
  List<Course> _rejectedCourses = [];
  List<Course> _pendingCourses = [];
  bool _isLoading = false;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _approvedCourses = [];
      _rejectedCourses = [];
      _pendingCourses = [];
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Bạn cần đăng nhập để xem khóa học của mình';
        });
        return;
      }

      // Tải tất cả khóa học của mentor và phân loại theo trạng thái
      final courses = await context.read<CourseCubit>().getMentorCourses(
        currentUser.uid,
      );

      // DEBUG: In ra dữ liệu khóa học
      _debugLogCourses(courses);

      // Phân loại khóa học theo trạng thái
      final approved = <Course>[];
      final rejected = <Course>[];
      final pending = <Course>[];

      for (final course in courses) {
        switch (course.status) {
          case 'approved':
            approved.add(course);
            break;
          case 'rejected':
            rejected.add(course);
            break;
          case 'pending':
            pending.add(course);
            break;
        }
      }

      setState(() {
        _approvedCourses = approved;
        _rejectedCourses = rejected;
        _pendingCourses = pending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách khóa học: $e';
      });
    }
  }

  // DEBUG: Hàm hiển thị thông tin khóa học để debug
  void _debugLogCourses(List<Course> courses) {
    print('===== DEBUG: MENTOR COURSES DATA =====');
    print('Total courses: ${courses.length}');

    print('\nApproved courses:');
    final approved = courses.where((c) => c.status == 'approved').toList();
    print('Count: ${approved.length}');
    for (var i = 0; i < approved.length; i++) {
      final c = approved[i];
      print('[$i] id: ${c.courseId}, title: ${c.title}, status: ${c.status}');
      print('    thumbnail: ${c.thumbnailUrl}');
      print(
        '    category: ${c.categoryName}, price: ${c.price}, discount: ${c.discountPrice}',
      );
      print(
        '    enroll: ${c.enrollCount}, lessons: ${c.lessonCount}, rating: ${c.rating}',
      );
    }

    print('\nPending courses:');
    final pending = courses.where((c) => c.status == 'pending').toList();
    print('Count: ${pending.length}');
    for (var i = 0; i < pending.length; i++) {
      final c = pending[i];
      print('[$i] id: ${c.courseId}, title: ${c.title}, status: ${c.status}');
    }

    print('\nRejected courses:');
    final rejected = courses.where((c) => c.status == 'rejected').toList();
    print('Count: ${rejected.length}');
    for (var i = 0; i < rejected.length; i++) {
      final c = rejected[i];
      print('[$i] id: ${c.courseId}, title: ${c.title}, status: ${c.status}');
      print('    rejectionReason: ${c.rejectionReason}');
    }

    print('=======================================');
  }

  // ============== Navigation helpers ==============
  Future<void> _addCourse() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CourseFormScreen(isEdit: false)),
    );
    if (result == true) {
      _fetchCourses(); // Refresh courses after adding a new one
    }
  }

  Future<void> _editCourse(Course course) async {
    final initialData = {
      'id': course.courseId,
      'title': course.title,
      'description': course.description,
      'category_id': course.categoryId,
      'price': course.price,
      'discount_price': course.discountPrice,
      'level': course.level,
      'thumbnail':
          course.thumbnailUrl != null
              ? '${ApiConfig.baseUrl}${course.thumbnailUrl}'
              : null,
      'instructor_uid': course.instructorUid,
    };
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => CourseFormScreen(isEdit: true, initialData: initialData),
      ),
    );
    if (result == true) {
      _fetchCourses(); // Refresh courses after editing
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: Text('Bạn chắc chắn muốn xoá "${course.title}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (ok ?? false) {
      try {
        // Lấy uid của mentor hiện tại
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
        }

        // Gọi API xóa khóa học
        await context.read<CourseCubit>().deleteCourse(
          courseId: course.courseId,
          instructorUid: currentUser.uid,
        );

        // Hiển thị thông báo thành công
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Đã xóa khóa học thành công',
        );

        // Refresh danh sách khóa học
        _fetchCourses();
      } catch (e) {
        // Hiển thị thông báo lỗi
        CustomSnackBar.showError(
          context: context,
          message: 'Không thể xóa khóa học: $e',
        );
      }
    }
  }

  // ============== UI ==============
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khóa học'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          labelColor: colors.primary,
          unselectedLabelColor: colors.onSurface.withOpacity(0.7),
          labelStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: theme.textTheme.titleMedium,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: colors.primary),
            insets: EdgeInsets.zero,
          ),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Đã duyệt'),
            Tab(text: 'Chờ duyệt'),
            Tab(text: 'Từ chối'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: LoadingIndicator())
              : _errorMessage != null
              ? _buildErrorWidget(theme, colors)
              : TabBarView(
                controller: _tabController,
                children: [
                  // Tab đã duyệt
                  RefreshIndicator(
                    onRefresh: _fetchCourses,
                    child: _buildCoursesList(
                      _approvedCourses,
                      theme,
                      colors,
                      'Đã duyệt',
                    ),
                  ),
                  // Tab chờ duyệt
                  RefreshIndicator(
                    onRefresh: _fetchCourses,
                    child: _buildCoursesList(
                      _pendingCourses,
                      theme,
                      colors,
                      'Chờ duyệt',
                    ),
                  ),
                  // Tab từ chối
                  RefreshIndicator(
                    onRefresh: _fetchCourses,
                    child: _buildCoursesList(
                      _rejectedCourses,
                      theme,
                      colors,
                      'Từ chối',
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        tooltip: 'Thêm khóa học mới',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodyLarge?.copyWith(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _fetchCourses,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(
    List<Course> courses,
    ThemeData theme,
    ColorScheme colors,
    String statusType,
  ) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có khóa học nào ở trạng thái $statusType',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (statusType == 'Từ chối')
              FilledButton.icon(
                onPressed: _addCourse,
                icon: const Icon(Icons.add),
                label: const Text('Tạo khóa học mới'),
              ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, index) {
        final course = courses[index];
        return _buildCourseCard(course, colors, theme, statusType);
      },
    );
  }

  Widget _buildCourseCard(
    Course course,
    ColorScheme colors,
    ThemeData theme, [
    String statusType = '',
  ]) {
    return Slidable(
      key: ValueKey(course.courseId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          // Nút sửa
          SlidableAction(
            onPressed: (_) => _editCourse(course),
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit_outlined,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            spacing: 0,
          ),

          // Nút xóa
          SlidableAction(
            onPressed: (_) => _deleteCourse(course),
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            spacing: 0,
          ),
        ],
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        color: colors.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToCourseDetail(course),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nội dung chính của card
              Container(
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- THUMB --------
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          course.thumbnailUrl != null
                              ? CachedNetworkImage(
                                imageUrl:
                                    '${ApiConfig.baseUrl}${course.thumbnailUrl}',
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                placeholder:
                                    (_, __) => Container(
                                      width: 90,
                                      height: 90,
                                      color: colors.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.image,
                                        size: 30,
                                        color: colors.onSurfaceVariant
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                errorWidget:
                                    (_, __, ___) =>
                                        _buildImageErrorWidget(colors),
                              )
                              : _buildImagePlaceholder(colors),
                    ),
                    const SizedBox(width: 16),

                    // -------- INFO --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            course.title,
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Price
                          _PriceTag(
                            price: course.price,
                            discount: course.discountPrice,
                            bgColor: colors.primary,
                          ),
                          const SizedBox(height: 6),

                          // Desc
                          SizedBox(
                            height: 36, // Đảm bảo luôn 2 dòng
                            child: Text(
                              course.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Stats row
                          Row(
                            children: [
                              _IconStat(
                                icon: Icons.people,
                                text: '${course.enrollCount} HV',
                              ),
                              _IconStat(
                                icon: Icons.menu_book,
                                text: '${course.lessonCount} bài',
                              ),
                              _IconStat(
                                icon: Icons.star,
                                text: course.rating.toStringAsFixed(1),
                              ),
                            ],
                          ),

                          // Lý do từ chối (nếu có)
                          if (course.status == 'rejected' &&
                              course.rejectionReason != null &&
                              statusType == 'Từ chối')
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: colors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Lý do từ chối: ${course.rejectionReason}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colors.error,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Rejection reason info button (shown only for long rejection reasons)
                    if (course.status == 'rejected' &&
                        course.rejectionReason != null &&
                        course.rejectionReason!.length > 30)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 2),
                        child: IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            color: colors.error,
                            size: 18,
                          ),
                          onPressed:
                              () => _showRejectionReason(
                                context,
                                course.rejectionReason!,
                              ),
                          tooltip: 'Xem lý do từ chối',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                  ],
                ),
              ),

              // Nút Gửi lại duyệt cho khóa học bị từ chối (nằm trong phần riêng biệt bên dưới)
              if (statusType == 'Từ chối')
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _resubmitCourse(course),
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: const Text('Gửi lại duyệt'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: colors.primary,
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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

  Widget _buildImageErrorWidget(ColorScheme colors) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 32,
            color: colors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            'Lỗi ảnh',
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colors) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: colors.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            'Không có ảnh',
            style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _navigateToCourseDetail(Course course) {
    // TODO: Update this when CourseDetailScreen is updated to use courseId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => CourseDetailScreen(
              course: {
                'id': course.courseId,
                'title': course.title,
                'description': course.description,
                'thumbnail_url': course.thumbnailUrl,
                'category_name': course.categoryName,
                'level': course.level,
                'price': course.price,
                'discount_price': course.discountPrice,
                'enrollment_count': course.enrollCount,
                'lessons': course.lessonCount,
                'rating': course.rating,
                'total_video_duration': course.totalDuration,
                'language': 'Tiếng Việt',
                'tags': '',
                'status': course.status == 'approved',
              },
            ),
      ),
    ).then((_) => _fetchCourses());
  }

  void _showRejectionReason(BuildContext context, String reason) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Lý do từ chối'),
            content: Text(reason),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  // Hàm xử lý gửi lại khóa học để duyệt
  Future<void> _resubmitCourse(Course course) async {
    try {
      // Hiện hộp thoại xác nhận
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Xác nhận gửi lại'),
              content: Text(
                'Bạn có chắc chắn muốn gửi lại khóa học "${course.title}" để duyệt không?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Gửi lại'),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        // Lấy uid của mentor hiện tại
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Bạn cần đăng nhập để thực hiện chức năng này');
        }

        // DEBUG: In thông tin trước khi gọi API
        print('\n===== DEBUG: RESUBMIT COURSE PARAMETERS =====');
        print('CourseId: ${course.courseId}');
        print('InstructorUid: ${currentUser.uid}');
        print('Current status: ${course.status}');
        print('Target status: pending');
        print('=======================================\n');

        // Gọi API cập nhật trạng thái khóa học sang pending (chờ duyệt)
        await context.read<CourseCubit>().resubmitCourse(
          course.courseId,
          instructorUid: currentUser.uid,
        );

        // Hiển thị thông báo thành công
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Đã gửi lại khóa học để duyệt',
        );

        // Refresh danh sách khóa học
        _fetchCourses();
      }
    } catch (e) {
      // Hiển thị thông báo lỗi
      CustomSnackBar.showError(
        context: context,
        message: 'Không thể gửi lại khóa học: $e',
      );
    }
  }
}

/*============= Widgets con =============*/
class _PriceTag extends StatelessWidget {
  final int price;
  final int discount;
  final Color bgColor;

  const _PriceTag({
    required this.price,
    required this.discount,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    String txt;
    if (discount > 0 && discount != price) {
      txt = '${_fmt(discount)}đ';
    } else if (price == 0) {
      txt = 'Miễn phí';
    } else {
      txt = '${_fmt(price)}đ';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        txt,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => '.',
  );
}

class _IconStat extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconStat({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 3),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
