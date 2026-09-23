import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';

class ListCoursescreen extends StatefulWidget {
  const ListCoursescreen({super.key});

  @override
  State<ListCoursescreen> createState() => _ListCoursescreenState();
}

class _ListCoursescreenState extends State<ListCoursescreen> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // Gọi API MỘT LẦN khi màn hình được tạo.
    //
    // Trước đây đoạn này nằm trong `build()`: mỗi lần widget cha rebuild
    // (đổi theme, xoay màn hình, mở bàn phím...) lại bắn thêm một request,
    // gây tải vô ích và làm nhấp nháy danh sách.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final searchTerm =
          ModalRoute.of(context)?.settings.arguments as String?;
      context.read<CourseCubit>().loadCourses(
        status: 'approved',
        search: searchTerm,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Gõ tới đâu gọi API tới đó sẽ bắn một request cho MỖI ký tự.
  /// Chờ người dùng ngừng gõ 400ms rồi mới tìm.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<CourseCubit>().loadCourses(
        status: 'approved',
        search: value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        title: 'Danh sách khoá học',
        onSearchChanged: _onSearchChanged,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<CourseCubit, CourseState>(
            builder: (context, state) {
              if (state is CourseLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: LoadingIndicator()),
                );
              }

              if (state is CourseError) {
                return EmptyStateWidget(
                  icon: Icons.cloud_off_rounded,
                  title: 'Không tải được danh sách khoá học',
                  message: state.message,
                  isError: true,
                  actionLabel: 'Thử lại',
                  onAction: () {
                    context.read<CourseCubit>().loadCourses(
                      status: 'approved',
                    );
                  },
                );
              }

              if (state is CourseLoaded) {
                if (state.courses.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'Không tìm thấy khoá học',
                    message: 'Thử từ khoá khác hoặc xoá bộ lọc tìm kiếm.',
                  );
                }

                return ListCoursesWidget(
                  courses: state.courses,
                  userUid: context.read<AuthCubit>().state.userId ?? '',
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
