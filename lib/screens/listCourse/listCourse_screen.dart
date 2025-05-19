import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';

class ListCoursescreen extends StatelessWidget {
  const ListCoursescreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Always load approved courses on build
    context.read<CourseCubit>().loadCourses(status: 'approved');
    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        showMenu: true,
        title: 'Danh sách khoá học',
        onSearchChanged: (value) {
          // Gọi API tìm kiếm ở đây
          context.read<CourseCubit>().loadCourses(
            status: 'approved',
            search: value,
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              BlocBuilder<CourseCubit, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return Center(child: LoadingIndicator());
                  }
                  if (state is CourseError) {
                    return Center(
                      child: Text(
                        'Lỗi: ${state.message}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }
                  if (state is CourseLoaded) {
                    return ListCoursesWidget(
                      courses: state.courses,
                      userUid: FirebaseAuth.instance.currentUser?.uid ?? '',
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
