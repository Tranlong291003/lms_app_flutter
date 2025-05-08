import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/cubit/courses/course_cubit.dart';

class ListCoursescreen extends StatelessWidget {
  const ListCoursescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        showMenu: true,
        title: 'Danh sách khoá học',
        onSearchChanged: (value) {
          // Gọi API tìm kiếm ở đây
          context.read<CourseCubit>().loadCourses(search: value);
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const CourseCategoryWidget(),
              BlocBuilder<CourseCubit, CourseState>(
                builder: (context, state) {
                  if (state is CourseLoading) {
                    return const Center(child: CircularProgressIndicator());
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
                    return ListCoursesWidget(courses: state.courses);
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
