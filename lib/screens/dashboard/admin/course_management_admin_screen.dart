import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/courses/courses_model.dart';

class CourseManagementAdminScreen extends StatefulWidget {
  const CourseManagementAdminScreen({super.key});

  @override
  State<CourseManagementAdminScreen> createState() =>
      _CourseManagementAdminScreenState();
}

class _CourseManagementAdminScreenState
    extends State<CourseManagementAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<CourseCubit>().fetchAllCourses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCourseDetail(BuildContext context, int courseId) {
    Navigator.pushNamed(context, AppRouter.courseDetail, arguments: courseId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý khóa học - Admin'),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: theme.textTheme.titleMedium,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: colorScheme.primary),
              insets: EdgeInsets.zero,
            ),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Đã duyệt'),
              Tab(text: 'Chờ duyệt'),
              Tab(text: 'Đã từ chối'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            SearchBarWidget(
              controller: _searchController,
              hintText: 'Tìm kiếm khóa học...',
              onFilter: () {
                _showFilterDialog(context);
              },
              onChanged: (value) {
                context.read<CourseCubit>().searchCourses(value);
              },
            ),
            Expanded(
              child: BlocBuilder<CourseCubit, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return const Center(child: LoadingIndicator());
                  }

                  if (state is CourseError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              context.read<CourseCubit>().fetchAllCourses();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CourseLoaded) {
                    return TabBarView(
                      children: [
                        // Tab 1: Khóa học đã duyệt
                        _buildCourseList(
                          isApproved: true,
                          courses:
                              state.courses
                                  .where((c) => c.status == 'approved')
                                  .toList(),
                        ),
                        // Tab 2: Khóa học chờ duyệt
                        _buildCourseList(
                          isApproved: false,
                          courses:
                              state.courses
                                  .where((c) => c.status == 'pending')
                                  .toList(),
                        ),
                        // Tab 3: Khóa học đã từ chối
                        _buildCourseList(
                          isApproved: false,
                          isRejected: true,
                          courses:
                              state.courses
                                  .where((c) => c.status == 'rejected')
                                  .toList(),
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text('Không có dữ liệu'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList({
    required bool isApproved,
    required List<Course> courses,
    bool isRejected = false,
  }) {
    if (courses.isEmpty) {
      return EmptyListWidget(
        icon:
            isApproved
                ? Icons.school
                : isRejected
                ? Icons.cancel_outlined
                : Icons.pending_actions,
        message:
            isApproved
                ? 'Chưa có khóa học nào đã duyệt'
                : isRejected
                ? 'Không có khóa học nào bị từ chối'
                : 'Không có khóa học nào đang chờ duyệt',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<CourseCubit>().fetchAllCourses();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          if (isRejected) {
            return CourseCardWidget(
              course: course,
              onViewDetail:
                  () => _navigateToCourseDetail(context, course.courseId),
              showRejectReason: true,
              showPrice: true,
            );
          } else if (isApproved) {
            return CourseCardWidget(
              course: course,
              onViewDetail:
                  () => _navigateToCourseDetail(context, course.courseId),
              showPrice: true,
            );
          } else {
            return PendingCourseCard(
              course: course,
              onApprove: () => _showApproveConfirmation(context, course),
              onReject: () => _showRejectDialog(context, course),
              onViewDetail:
                  () => _navigateToCourseDetail(context, course.courseId),
            );
          }
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lọc khóa học'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Add filter options
              const Text('Chức năng đang phát triển'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }

  void _showApproveConfirmation(BuildContext context, Course course) {
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận duyệt khóa học'),
          content: Text(
            'Bạn có chắc chắn muốn duyệt khóa học "${course.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await context.read<CourseCubit>().approveCourse(
                    course.courseId,
                    adminUid: adminUid,
                  );
                  if (context.mounted) {
                    CustomSnackBar.showSuccess(
                      context: context,
                      message: 'Duyệt khóa học thành công!',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    CustomSnackBar.showError(
                      context: context,
                      message: 'Duyệt khóa học thất bại!',
                    );
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Duyệt'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, Course course) {
    final reasonController = TextEditingController();
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Danh sách các lý do từ chối phổ biến
    final List<String> commonReasons = [
      'Nội dung không đáp ứng tiêu chuẩn chất lượng',
      'Thông tin khóa học không đầy đủ',
      'Hình ảnh không phù hợp hoặc thiếu chuyên nghiệp',
      'Nội dung vi phạm điều khoản sử dụng',
      'Trùng lặp với khóa học đã có',
      'Mô tả khóa học không rõ ràng hoặc sai lệch',
      'Giáo trình không đầy đủ hoặc thiếu logic',
    ];

    // Theo dõi lý do nào đã được chọn
    final selectedReasons = <String>{};

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Từ chối khóa học'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khóa học: ${course.title}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Chọn lý do từ chối:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Danh sách các lý do phổ biến để chọn
                    ...commonReasons.map(
                      (reason) => CheckboxListTile(
                        title: Text(reason, style: TextStyle(fontSize: 14)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: selectedReasons.contains(reason),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedReasons.add(reason);
                            } else {
                              selectedReasons.remove(reason);
                            }

                            // Cập nhật nội dung trong text field
                            reasonController.text = selectedReasons.join('\n');
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lý do cụ thể:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      decoration: InputDecoration(
                        hintText: 'Nhập hoặc chỉnh sửa lý do từ chối',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (reasonController.text.trim().isEmpty) {
                      CustomSnackBar.showError(
                        context: context,
                        message: 'Vui lòng nhập lý do từ chối',
                      );
                      return;
                    }

                    try {
                      await context.read<CourseCubit>().rejectCourse(
                        course.courseId,
                        reasonController.text,
                        adminUid: adminUid,
                      );
                      if (context.mounted) {
                        CustomSnackBar.showSuccess(
                          context: context,
                          message: 'Từ chối khóa học thành công!',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        CustomSnackBar.showError(
                          context: context,
                          message: 'Từ chối khóa học thất bại!',
                        );
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Từ chối'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// Widget hiển thị khi danh sách trống
class EmptyListWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyListWidget({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget hiển thị card khóa học (chung cho đã duyệt và từ chối)
class CourseCardWidget extends StatelessWidget {
  final Course course;
  final VoidCallback onViewDetail;
  final bool showRejectReason;
  final bool showPrice;

  const CourseCardWidget({
    super.key,
    required this.course,
    required this.onViewDetail,
    this.showRejectReason = false,
    this.showPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseThumbnail(
              thumbnail: course.thumbnailUrl,
              category: course.categoryName,
              price: course.price.toDouble(),
              showPriceTag: showPrice,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row with rating
                  MentorInfo(
                    name: course.instructorName,
                    avatar: course.instructorAvatar,
                    rating: course.rating,
                    totalReviews: course.enrollCount,
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    course.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Rejection reason if applicable
                  if (showRejectReason && course.rejectionReason != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Lý do từ chối:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course.rejectionReason ?? 'Không có lý do',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  CourseStatsRow(
                    lessons: course.lessonCount,
                    duration: _parseDuration(course.totalDuration),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewDetail,
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('Xem chi tiết'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.primary.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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

  double _parseDuration(String duration) {
    try {
      final parts = duration.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return hours + (minutes / 60) + (seconds / 3600);
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }
    return 0;
  }
}

// Widget hiển thị card khóa học chờ duyệt
class PendingCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onViewDetail;

  const PendingCourseCard({
    super.key,
    required this.course,
    required this.onApprove,
    required this.onReject,
    required this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseThumbnail(
              thumbnail: course.thumbnailUrl,
              category: course.categoryName,
              price: course.price.toDouble(),
              showPriceTag: true,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row with rating
                  MentorInfo(
                    name: course.instructorName,
                    avatar: course.instructorAvatar,
                    rating: course.rating,
                    totalReviews: course.enrollCount,
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    course.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  CourseStatsRow(
                    lessons: course.lessonCount,
                    duration: _parseDuration(course.totalDuration),
                  ),

                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onViewDetail,
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('Xem chi tiết'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Duyệt'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: Icon(Icons.close, color: Colors.red, size: 18),
                          label: Text(
                            'Từ chối',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _parseDuration(String duration) {
    try {
      final parts = duration.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return hours + (minutes / 60) + (seconds / 3600);
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }
    return 0;
  }
}

// Widget hiển thị thống kê khóa học
class CourseStatsRow extends StatelessWidget {
  final int lessons;
  final double duration;

  const CourseStatsRow({
    super.key,
    required this.lessons,
    required this.duration,
  });

  String _formatDuration(double hours) {
    final int totalMinutes = (hours * 60).round();
    final int displayHours = totalMinutes ~/ 60;
    final int displayMinutes = totalMinutes % 60;

    if (displayHours > 0) {
      return '$displayHours giờ ${displayMinutes > 0 ? '$displayMinutes phút' : ''}';
    } else {
      return '$displayMinutes phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Row(
          children: [
            Icon(Icons.menu_book_outlined, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              "$lessons",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "Bài học",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              _formatDuration(duration),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Widget hiển thị thumbnail khóa học
class CourseThumbnail extends StatelessWidget {
  final String? thumbnail;
  final String category;
  final double? price;
  final bool showPriceTag;

  const CourseThumbnail({
    super.key,
    this.thumbnail,
    required this.category,
    this.price,
    this.showPriceTag = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child:
                thumbnail != null
                    ? Image.network(
                      '${ApiConfig.baseUrl}$thumbnail',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.primary.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: colorScheme.primary.withOpacity(0.4),
                              size: 40,
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      color: colorScheme.primary.withOpacity(0.1),
                      child: Center(
                        child: Icon(
                          Icons.photo_outlined,
                          color: colorScheme.primary.withOpacity(0.4),
                          size: 40,
                        ),
                      ),
                    ),
          ),
          // Category tag
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Price tag
          if (showPriceTag && price != null)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: price! > 0 ? colorScheme.tertiary : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  price! > 0 ? '${price!.toStringAsFixed(0)} VNĐ' : 'Miễn phí',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget hiển thị thông tin mentor
class MentorInfo extends StatelessWidget {
  final String name;
  final String? avatar;
  final double? rating;
  final int? totalReviews;

  const MentorInfo({
    super.key,
    required this.name,
    this.avatar,
    this.rating,
    this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          backgroundImage:
              avatar != null
                  ? NetworkImage('${ApiConfig.baseUrl}$avatar')
                  : null,
          child:
              avatar == null
                  ? Icon(Icons.person, color: colorScheme.primary, size: 16)
                  : null,
        ),
        const SizedBox(width: 8),
        Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        if (rating != null && rating! > 0) ...[
          const Spacer(),
          Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalReviews != null) ...[
            const SizedBox(width: 4),
            Text(
              '($totalReviews)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ],
    );
  }
}
