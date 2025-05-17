import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_cubit.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_state.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/myCourse/course_card_widget.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _cubit.loadEnrolledCourses(user.uid);
    }
  }

  void _navigateToCourseDetail(BuildContext context, int courseId) {
    // Tạo CourseDetailCubit và chuyển đến màn hình chi tiết khóa học
    final courseDetailCubit = CourseDetailCubit(
      CourseRepository(Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã xảy ra lỗi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEnrolledCourses,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is EnrolledCourseLoaded) {
            if (state.completedCourses.isEmpty) {
              return Center(
                child: Text(
                  'Bạn chưa hoàn thành khóa học nào',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadEnrolledCourses(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.completedCourses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final course = state.completedCourses[index];
                  final double percent = 1.0; // Đã hoàn thành 100%

                  return CourseCard(
                    thumbnail: course.thumbnailUrl ?? "",
                    title: course.title,
                    duration: course.totalDuration,
                    progressValue: percent,
                    progressColor: const Color(
                      0xFF2F56DD,
                    ), // màu xanh dương mặc định
                    progressText:
                        "${course.completedLessons}/${course.totalLessons} bài",
                    showCircular: widget.showCircular,
                    onTap:
                        () => _navigateToCourseDetail(context, course.courseId),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
