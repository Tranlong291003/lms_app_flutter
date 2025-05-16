import 'package:flutter/material.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý khóa học'),
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDark ? colorScheme.primary : colorScheme.onPrimary,
          indicatorWeight: 3,
          labelColor: isDark ? colorScheme.primary : colorScheme.onPrimary,
          unselectedLabelColor:
              isDark
                  ? colorScheme.onSurface.withOpacity(0.7)
                  : colorScheme.onPrimary.withOpacity(0.7),
          labelStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [Tab(text: 'Đã duyệt'), Tab(text: 'Chờ duyệt')],
        ),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Tìm kiếm khóa học...',
            onFilter: () {
              _showFilterDialog(context);
            },
            onChanged: (value) {
              // TODO: Thực hiện tìm kiếm
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Khóa học đã duyệt
                _buildCourseList(
                  isApproved: true,
                  courses: _getApprovedCourses(),
                ),

                // Tab 2: Khóa học chờ duyệt
                _buildCourseList(
                  isApproved: false,
                  courses: _getPendingCourses(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList({
    required bool isApproved,
    required List<CourseModel> courses,
  }) {
    if (courses.isEmpty) {
      return EmptyListWidget(
        icon: isApproved ? Icons.school : Icons.pending_actions,
        message:
            isApproved
                ? 'Chưa có khóa học nào đã duyệt'
                : 'Không có khóa học nào đang chờ duyệt',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Refresh data
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return isApproved
              ? ApprovedCourseCard(
                course: course,
                onViewDetail: () => _showCourseDetails(context, course),
              )
              : PendingCourseCard(
                course: course,
                onApprove: () => _showApproveConfirmation(context, course),
                onReject: () => _showRejectDialog(context, course),
              );
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

  void _showApproveConfirmation(BuildContext context, CourseModel course) {
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
              onPressed: () {
                // TODO: Approve course
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã duyệt khóa học "${course.title}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Duyệt'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, CourseModel course) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Từ chối khóa học'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khóa học: ${course.title}'),
              const SizedBox(height: 16),
              const Text('Lý do từ chối:'),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Nhập lý do từ chối khóa học',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Reject course
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã từ chối khóa học "${course.title}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, CourseModel course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa khóa học'),
          content: Text(
            'Bạn có chắc chắn muốn xóa khóa học "${course.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Delete course
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa khóa học "${course.title}"'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  // Fake data for UI
  List<CourseModel> _getApprovedCourses() {
    return [
      CourseModel(
        id: 1,
        title: 'Lập trình Flutter cơ bản đến nâng cao',
        description:
            'Khóa học toàn diện về Flutter từ cơ bản đến nâng cao với nhiều ví dụ thực tế và dự án thực hành.',
        thumbnail: 'https://picsum.photos/seed/flutter/400/200',
        category: 'Lập trình',
        price: 699000,
        rating: 4.8,
        totalReviews: 128,
        enrollments: 256,
        lessons: 48,
        duration: 32.5,
        mentorName: 'Nguyễn Văn A',
        mentorAvatar: 'https://picsum.photos/seed/mentor1/100/100',
        isApproved: true,
      ),
      CourseModel(
        id: 2,
        title: 'Machine Learning với Python',
        description:
            'Tìm hiểu về các thuật toán Machine Learning và cách áp dụng chúng vào các bài toán thực tế.',
        thumbnail: 'https://picsum.photos/seed/ml/400/200',
        category: 'AI & ML',
        price: 899000,
        rating: 4.7,
        totalReviews: 95,
        enrollments: 180,
        lessons: 36,
        duration: 28,
        mentorName: 'Trần Thị B',
        mentorAvatar: 'https://picsum.photos/seed/mentor2/100/100',
        isApproved: true,
      ),
      CourseModel(
        id: 3,
        title: 'Thiết kế UI/UX chuyên nghiệp với Figma',
        description:
            'Khóa học giúp bạn nắm vững các nguyên tắc thiết kế UI/UX và thành thạo công cụ Figma.',
        thumbnail: 'https://picsum.photos/seed/uiux/400/200',
        category: 'Thiết kế',
        price: 599000,
        rating: 4.9,
        totalReviews: 156,
        enrollments: 320,
        lessons: 28,
        duration: 24,
        mentorName: 'Lê Văn C',
        mentorAvatar: 'https://picsum.photos/seed/mentor3/100/100',
        isApproved: true,
      ),
    ];
  }

  List<CourseModel> _getPendingCourses() {
    return [
      CourseModel(
        id: 4,
        title: 'React Native cho người mới bắt đầu',
        description:
            'Học cách xây dựng ứng dụng di động đa nền tảng với React Native từ cơ bản đến nâng cao.',
        thumbnail: 'https://picsum.photos/seed/react/400/200',
        category: 'Lập trình',
        price: 799000,
        rating: 0,
        totalReviews: 0,
        enrollments: 0,
        lessons: 42,
        duration: 30,
        mentorName: 'Phạm Thị D',
        mentorAvatar: 'https://picsum.photos/seed/mentor4/100/100',
        isApproved: false,
      ),
      CourseModel(
        id: 5,
        title: 'DevOps và CI/CD Pipeline',
        description:
            'Tìm hiểu về các quy trình và công cụ DevOps hiện đại để tự động hóa quy trình phát triển phần mềm.',
        thumbnail: 'https://picsum.photos/seed/devops/400/200',
        category: 'Cloud & DevOps',
        price: 999000,
        rating: 0,
        totalReviews: 0,
        enrollments: 0,
        lessons: 35,
        duration: 28.5,
        mentorName: 'Hoàng Văn E',
        mentorAvatar: 'https://picsum.photos/seed/mentor5/100/100',
        isApproved: false,
      ),
    ];
  }

  void _showCourseDetails(BuildContext context, CourseModel course) {
    // Implement the logic to show course details
  }
}

class CourseModel {
  final int id;
  final String title;
  final String description;
  final String? thumbnail;
  final String category;
  final double price;
  final double rating;
  final int totalReviews;
  final int enrollments;
  final int lessons;
  final double duration;
  final String mentorName;
  final String? mentorAvatar;
  final bool isApproved;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.category,
    required this.price,
    required this.rating,
    required this.totalReviews,
    required this.enrollments,
    required this.lessons,
    required this.duration,
    required this.mentorName,
    this.mentorAvatar,
    required this.isApproved,
  });
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

// Widget hiển thị card khóa học đã được duyệt
class ApprovedCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onViewDetail;

  const ApprovedCourseCard({
    super.key,
    required this.course,
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
              thumbnail: course.thumbnail,
              category: course.category,
              price: course.price,
              showPriceTag: true,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row with rating
                  MentorInfo(
                    name: course.mentorName,
                    avatar: course.mentorAvatar,
                    rating: course.rating,
                    totalReviews: course.totalReviews,
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
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  CourseStatsRow(
                    lessons: course.lessons,
                    duration: course.duration,
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
}

// Widget hiển thị card khóa học chờ duyệt
class PendingCourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const PendingCourseCard({
    super.key,
    required this.course,
    required this.onApprove,
    required this.onReject,
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
              thumbnail: course.thumbnail,
              category: course.category,
              price: course.price,
              showPriceTag: false,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author row
                  MentorInfo(
                    name: course.mentorName,
                    avatar: course.mentorAvatar,
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    course.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Course stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CourseStatsRow(
                lessons: course.lessons,
                duration: course.duration,
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onApprove,
                    child: Container(
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duyệt',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: onReject,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Từ chối',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              "$duration",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "giờ",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
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
                      thumbnail!,
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
          backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
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
