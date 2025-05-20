import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_cubit.dart';
import 'package:lms/screens/myCourse/my_completed_courses.dart';
import 'package:lms/screens/myCourse/my_ongoing_courses.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  bool showCircular = false;
  late EnrolledCourseCubit _enrolledCourseCubit;

  @override
  void initState() {
    super.initState();
    _enrolledCourseCubit = EnrolledCourseCubit();
    _loadEnrolledCourses();
  }

  @override
  void dispose() {
    _enrolledCourseCubit.close();
    super.dispose();
  }

  void _loadEnrolledCourses() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _enrolledCourseCubit.loadEnrolledCourses(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _enrolledCourseCubit,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'Khoá học của tôi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withOpacity(0.7),
              labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3,
                  color: Theme.of(context).colorScheme.primary,
                ),
                insets: EdgeInsets.zero,
              ),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [Tab(text: 'Đang học'), Tab(text: 'Đã hoàn thành')],
            ),
          ),
          body: TabBarView(
            children: [
              MyOngoingCoursesScreen(
                showCircular: showCircular,
                enrolledCourseCubit: _enrolledCourseCubit,
              ),
              MyCompletedCoursesScreen(
                showCircular: showCircular,
                enrolledCourseCubit: _enrolledCourseCubit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
