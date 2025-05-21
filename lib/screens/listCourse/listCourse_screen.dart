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
    // Nhận từ khóa tìm kiếm từ arguments, nếu có
    final String? searchTerm =
        ModalRoute.of(context)?.settings.arguments as String?;

    // Luôn tải khóa học khi màn hình được build
    // Nếu có từ khóa tìm kiếm, sử dụng nó. Ngược lại, chỉ tải các khóa học đã duyệt.
    context.read<CourseCubit>().loadCourses(
      status:
          'approved', // Vẫn chỉ hiển thị khóa học đã duyệt trên màn hình này
      search: searchTerm, // Sử dụng từ khóa tìm kiếm nếu có
    );

    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        showMenu: true,
        title: 'Danh sách khoá học',
        onSearchChanged: (value) {
          // Gọi API tìm kiếm ở đây khi người dùng gõ trong SearchBar của ListCoursescreen
          // (Giữ nguyên chức năng tìm kiếm trên AppBar của ListCoursescreen)
          context.read<CourseCubit>().loadCourses(
            status: 'approved',
            search: value,
          );
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
