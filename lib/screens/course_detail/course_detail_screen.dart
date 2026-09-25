import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/screens/course_detail/course_stats_section.dart';
import 'package:lms/screens/course_detail/course_tab_view.dart';
import 'package:lms/screens/course_detail/course_title.dart';
import 'package:lms/screens/course_detail/enroll_button.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/services/bookmark_service.dart';
import 'package:lms/services/course_service.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late BookmarkCubit _bookmarkCubit;

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthCubit>().state.userId;
    final bookmarkService = BookmarkService();
    final bookmarkRepository = BookmarkRepository(bookmarkService);
    _bookmarkCubit = BookmarkCubit(bookmarkRepository);
    if (uid != null && uid.isNotEmpty) {
      _bookmarkCubit.getBookmarks(uid);
    }
  }

  @override
  void dispose() {
    _bookmarkCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CourseDetailCubit, CourseDetailState>(
      builder: (context, state) {
        // Cả trạng thái lỗi lẫn đang tải trước đây đều trả về một `Scaffold`
        // KHÔNG có `appBar` — người dùng nhìn thấy màn hình trắng/trống và
        // không có nút quay lại, chỉ thoát được bằng cử chỉ hệ thống.
        if (state is CourseDetailError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: const CustomAppBar(title: 'Khoá học', showBack: true),
            body: EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được khoá học',
              message: state.message,
              isError: true,
              actionLabel: 'Thử lại',
              onAction:
                  () => context.read<CourseDetailCubit>().fetchCourseDetail(
                    widget.courseId,
                  ),
            ),
          );
        }

        if (state is CourseDetailLoaded) {
          final detail = state.detail;
          final userUid = context.read<AuthCubit>().state.userId ?? '';
          return BlocProvider.value(
            value: _bookmarkCubit,
            child: Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: CustomScrollView(
                slivers: [
                  CourseAppBarDynamic(
                    imageUrl: ApiConfig.getImageUrl(detail.thumbnailUrl),
                  ),
                  SliverToBoxAdapter(child: _CourseBody(detail: detail)),
                ],
              ),
              bottomNavigationBar: FutureBuilder<bool>(
                future: CourseService().checkEnrollment(
                  userUid: userUid,
                  courseId: detail.courseId,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        minimum: const EdgeInsets.all(20),
                        child: SizedBox(
                          height: 48,
                          child: Center(child: LoadingIndicator()),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData && snapshot.data == true) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      minimum: const EdgeInsets.all(20),
                      child: EnrollButton(
                        userUid: userUid,
                        courseId: detail.courseId,
                        price: detail.price,
                        discountPrice: detail.discountPrice,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        // Đang tải (và mọi trạng thái chưa xác định khác).
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: const CustomAppBar(title: 'Khoá học', showBack: true),
          body: const Center(child: LoadingIndicator()),
        );
      },
    );
  }
}

class CourseAppBarDynamic extends StatelessWidget {
  final String? imageUrl;
  const CourseAppBarDynamic({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 16),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      // Ảnh bìa phải chừa vùng tai thỏ/status bar: nếu để `FlexibleSpaceBar`
      // tràn lên trên thì nút back chồng lên đồng hồ hệ thống và ảnh bị thanh
      // trạng thái cắt mất phần trên.
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          top: true,
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        color: theme.scaffoldBackgroundColor,
                        child: Icon(
                          Icons.broken_image,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                )
              else
                Container(
                  color: theme.scaffoldBackgroundColor,
                  child: Icon(
                    Icons.image,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseBody extends StatelessWidget {
  final CourseDetail detail;
  const _CourseBody({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(
            top: AppSpacing.xxl,
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            // Nút "Đăng ký học" nằm trong `bottomNavigationBar`, tức là ĐÈ LÊN
            // phần cuối của danh sách chứ không đẩy nó lên. Đệm đáy phải chừa
            // đủ chỗ cho thanh đó, nếu không thẻ cuối cùng sẽ bị che.
            bottom: AppSpacing.xl * 4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CourseTitle(title: detail.title, courseId: detail.courseId),
              const SizedBox(height: 16),
              CourseStatsSection(
                category: detail.categoryName,
                rating: detail.avgRating,
                reviewCount: detail.reviewCount,
                enrollmentCount: detail.enrollmentCount,
                duration: detail.totalVideoDuration,
                price: detail.price,
                discountPrice: detail.discountPrice,
              ),
              const SizedBox(height: 24),
              CourseTabView(
                courseId: detail.courseId,
                description: detail.description,
                instructorName: detail.instructorName,
                instructorUid: detail.instructorUid,
                instructorAvatarUrl: detail.instructorAvatarUrl,
                instructorBio: detail.instructorBio,
                language: detail.language,
                tags: detail.tags,
                level: detail.level,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
