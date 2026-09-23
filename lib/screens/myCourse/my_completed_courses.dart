import 'package:flutter/material.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_cubit.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_state.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/myCourse/course_card_widget.dart';
import 'package:lms/services/course_service.dart';

class MyCompletedCoursesScreen extends StatefulWidget {
  final bool showCircular;
  final EnrolledCourseCubit? enrolledCourseCubit;

  const MyCompletedCoursesScreen({
    super.key,
    required this.showCircular,
    this.enrolledCourseCubit,
  });

  @override
  State<MyCompletedCoursesScreen> createState() =>
      _MyCompletedCoursesScreenState();
}

class _MyCompletedCoursesScreenState extends State<MyCompletedCoursesScreen> {
  late EnrolledCourseCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget.enrolledCourseCubit ?? EnrolledCourseCubit();
    if (widget.enrolledCourseCubit == null) {
      _loadEnrolledCourses();
    }
  }

  @override
  void dispose() {
    // Chỉ đóng cubit nếu nó được tạo trong widget này
    if (widget.enrolledCourseCubit == null) {
      _cubit.close();
    }
    super.dispose();
  }

  void _loadEnrolledCourses() {
    final uid = context.read<AuthCubit>().state.userId;
    if (uid != null && uid.isNotEmpty) {
      _cubit.loadEnrolledCourses(uid);
    }
  }

  void _navigateToCourseDetail(BuildContext context, int courseId) {
    // Tạo CourseDetailCubit và chuyển đến màn hình chi tiết khóa học
    final courseDetailCubit = CourseDetailCubit(
      CourseRepository(CourseService()),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create:
                  (context) => courseDetailCubit..fetchCourseDetail(courseId),
              child: CourseDetailScreen(courseId: courseId),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<EnrolledCourseCubit, EnrolledCourseState>(
        builder: (context, state) {
          if (state is EnrolledCourseLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is EnrolledCourseError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được danh sách khoá học',
              message: state.message,
              isError: true,
              actionLabel: 'Thử lại',
              onAction: _loadEnrolledCourses,
            );
          } else if (state is EnrolledCourseLoaded) {
            if (state.completedCourses.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.menu_book_outlined,
                title: 'Bạn chưa hoàn thành khoá học nào',
                message: 'Hoàn thành các bài giảng để khoá học xuất hiện ở đây.',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadEnrolledCourses(),
              child: ListView.separated(
                padding: listPaddingWithBottomInset(context),
                itemCount: state.completedCourses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final course = state.completedCourses[index];

                  return CourseCard(
                    thumbnail: course.thumbnailUrl ?? "",
                    title: course.title,
                    duration: course.totalDuration,
                    completedLessons: course.completedLessons,
                    totalLessons: course.totalLessons,
                    onTap:
                        () => _navigateToCourseDetail(context, course.courseId),
                  );
                },
              ),
            );
          }

          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }
}
