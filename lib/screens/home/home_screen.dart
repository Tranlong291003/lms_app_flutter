import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/apps/utils/route_observer.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/mentors/mentors_event.dart';
import 'package:lms/blocs/mentors/mentors_state.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/screens/home/appBar_widget.dart';
import 'package:lms/screens/home/discountSlider_widget.dart';
import 'package:lms/screens/home/topMentors_widget.dart';
import 'package:lms/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(token: FirebaseAuth.instance.currentUser?.uid);
    _loadMentor();
    _loadCurrentUser();
    _loadCourses();
    _checkUserActive();
    context.read<CategoryCubit>().fetchAllCategory();
  }

  Future<void> _checkUserActive() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final isActive = await _userService.checkUserActive(currentUser.uid);
        if (!isActive) {
          await _handleInactiveUser();
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Lỗi kiểm tra trạng thái tài khoản';

          // Handle specific Firebase Auth errors
          if (e.toString().contains('account has been disabled')) {
            await _handleInactiveUser();
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _handleInactiveUser() async {
    if (!mounted) return;

    // Show message first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tài khoản của bạn đã bị vô hiệu hóa bởi quản trị viên.'),
        duration: Duration(seconds: 3),
      ),
    );

    // Wait for message to be shown
    await Future.delayed(const Duration(seconds: 1));

    // Sign out
    await FirebaseAuth.instance.signOut();

    // Wait for sign out to complete
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Navigate to login screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.login,
      (route) => false,
    );
  }

  void _loadMentor() {
    context.read<MentorsBloc>().add(GetAllMentorsEvent());
  }

  void _loadCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<UserBloc>().add(GetUserByUidEvent(uid));
    }
  }

  void _loadCourses() {
    context.read<CourseCubit>().loadCourses(status: 'approved');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Khi quay lại từ trang khác, reload lại courses và kiểm tra active status
    _loadCourses();
    _checkUserActive();
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBarHome(context, 'title'),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCourses();
          context.read<MentorsBloc>().add(RefreshMentorsEvent());
          context.read<UserBloc>().add(RefreshUserEvent());
          context.read<CategoryCubit>().refreshCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(
                  onChanged: (value) {
                    // Tìm kiếm trong danh sách khóa học
                    final courseState = context.read<CourseCubit>().state;
                    if (courseState is CourseLoaded) {
                      var filteredCourses = courseState.randomCourses;
                      if (value.isNotEmpty) {
                        filteredCourses =
                            filteredCourses.where((course) {
                              final title = course.title.toLowerCase();
                              final description =
                                  course.description.toLowerCase();
                              final searchTerm = value.toLowerCase();
                              return title.contains(searchTerm) ||
                                  description.contains(searchTerm);
                            }).toList();
                      }
                      // Cập nhật danh sách khóa học đã lọc
                      context.read<CourseCubit>().updateFilteredCourses(
                        filteredCourses,
                      );
                    }
                  },
                  onFilter: () {
                    // TODO: Thêm chức năng lọc nâng cao
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tính năng đang được phát triển'),
                      ),
                    );
                  },
                  hintText: 'Tìm kiếm khóa học...',
                ),
                DiscountSlider(),
                _buildSection(
                  title: 'Danh sách giảng viên',
                  onTap:
                      () => Navigator.pushNamed(context, AppRouter.listMentor),
                  child: BlocBuilder<MentorsBloc, MentorsState>(
                    builder: (context, state) {
                      if (state is MentorsLoading) {
                        return const LoadingIndicator();
                      } else if (state is MentorsLoaded) {
                        return TopMentors(mentors: state.mentors);
                      } else if (state is MentorsError) {
                        return Center(child: Text('Lỗi: ${state.message}'));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _buildSection(
                  title: 'Danh sách khoá học',
                  onTap:
                      () => Navigator.pushNamed(context, AppRouter.listCourse),
                  child: Column(
                    children: [
                      CourseCategoryWidget(),
                      const SizedBox(height: 20),
                      BlocBuilder<CourseCubit, CourseState>(
                        builder: (context, courseState) {
                          if (courseState is CourseLoading) {
                            return const SizedBox(
                              height: 200,
                              child: Center(child: LoadingIndicator()),
                            );
                          } else if (courseState is CourseLoaded) {
                            var list = courseState.randomCourses;
                            final categoryState =
                                context.watch<CategoryCubit>().state;
                            if (categoryState is CategoryLoaded &&
                                categoryState.selectedId != null) {
                              list =
                                  list
                                      .where(
                                        (c) =>
                                            c.categoryId ==
                                            categoryState.selectedId,
                                      )
                                      .toList();
                            }

                            if (list.isEmpty) {
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school_outlined,
                                        size: 64,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Chưa có khóa học nào',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<CategoryCubit>()
                                              .selectCategory(null);
                                          _loadCourses();
                                        },
                                        child: const Text('Làm mới'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListCoursesWidget(
                              courses: list,
                              userUid:
                                  FirebaseAuth.instance.currentUser?.uid ?? '',
                            );
                          } else if (courseState is CourseError) {
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Lỗi: ${courseState.message}',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        _loadCourses();
                                      },
                                      child: const Text('Thử lại'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox(height: 200);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(onPressed: onTap, child: const Text('Xem tất cả')),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
