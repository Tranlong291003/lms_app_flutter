import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/screens/course_detail/course_stats_section.dart';
import 'package:lms/screens/course_detail/course_tab_view.dart';
import 'package:lms/screens/course_detail/course_title.dart';
import 'package:lms/screens/course_detail/enroll_button.dart';
import 'package:lms/services/course_service.dart';

class CourseDetailScreen extends StatelessWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CourseDetailCubit, CourseDetailState>(
      builder: (context, state) {
        if (state is CourseDetailLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: const Center(child: LoadingIndicator()),
          );
        }
        if (state is CourseDetailLoaded) {
          final detail = state.detail;
          final user = FirebaseAuth.instance.currentUser;
          final userUid = user?.uid ?? '';
          return Scaffold(
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
                  // Có thể show loading hoặc để trống
                  return const SizedBox.shrink();
                }
                if (snapshot.hasData && snapshot.data == true) {
                  // Đã đăng ký, ẩn hoàn toàn
                  return const SizedBox.shrink();
                }
                // Chưa đăng ký, hiển thị nút
                return Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
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
                    ),
                  ),
                );
              },
            ),
          );
        }
        if (state is CourseDetailError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
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
            color: theme.scaffoldBackgroundColor.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 16),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
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
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
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
            top: 24,
            left: 20,
            right: 20,
            bottom: 20,
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
              ),
              const SizedBox(height: 24),
              CourseTabView(
                courseId: detail.courseId,
                description: detail.description,
                instructorName: detail.instructorName,
                instructorAvatarUrl: detail.instructorAvatarUrl,
                instructorBio: detail.instructorBio,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
