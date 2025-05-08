import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/blocs/cubit/courses/course_cubit.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/screens/course_detail/course_stats_section.dart';
import 'package:lms/screens/course_detail/course_tab_view.dart';
import 'package:lms/screens/course_detail/course_title.dart';
import 'package:lms/screens/course_detail/enroll_button.dart';

class CourseDetailScreen extends StatelessWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseDetailCubit, CourseDetailState>(
      builder: (context, state) {
        if (state is CourseDetailLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CourseDetailLoaded) {
          final detail = state.detail;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: CustomScrollView(
              slivers: [
                CourseAppBarDynamic(
                  imageUrl: '${ApiConfig.baseUrl}${detail.thumbnailUrl}',
                ),
                SliverToBoxAdapter(child: _CourseBody(detail: detail)),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: const SafeArea(
                minimum: EdgeInsets.all(20),
                child: EnrollButton(),
              ),
            ),
          );
        }
        if (state is CourseDetailError) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${state.message}',
                    style: Theme.of(context).textTheme.titleMedium,
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
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
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
                      color: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
              )
            else
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.image,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
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
            color: theme.colorScheme.surface,
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
              CourseTitle(title: detail.title),
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
