import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
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
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/screens/home/appBar_widget.dart';
import 'package:lms/screens/home/discountSlider_widget.dart';
import 'package:lms/screens/home/topMentors_widget.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final UserService _userService;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    if (_isFirstLoad) {
      _loadMentor();
      _loadCurrentUser();
      _loadCourses();
      _checkUserActive();
      context.read<CategoryCubit>().fetchAllCategory();
      // Số thông báo chưa đọc hiện trên app bar, nên phải nạp ở đây. Trước đây
      // lời gọi nằm trong `addPostFrameCallback` bên trong app bar — chạy lại
      // mỗi lần app bar dựng lại, tức là bắn một request mỗi lần nhấn vào tab.
      context.read<NotificationCubit>().loadNotifications();
      _isFirstLoad = false;
    }
  }

  Future<void> _checkUserActive() async {
    final uid = context.read<AuthCubit>().state.userId;
    if (uid != null && uid.isNotEmpty) {
      try {
        final isActive = await _userService.checkUserActive(uid);
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

    // Giữ sẵn cubit trước khi await: sau `await` widget có thể đã bị huỷ và
    // `context` không còn dùng được.
    final authCubit = context.read<AuthCubit>();

    // Show message first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tài khoản của bạn đã bị vô hiệu hóa bởi quản trị viên.'),
        duration: Duration(seconds: 3),
      ),
    );

    // Wait for message to be shown
    await Future.delayed(const Duration(seconds: 1));

    await authCubit.logout();
  }

  void _loadMentor() {
    context.read<MentorsBloc>().add(GetAllMentorsEvent());
  }

  void _loadCurrentUser() {
    final uid = context.read<AuthCubit>().state.userId;
    if (uid != null && uid.isNotEmpty) {
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
    // KHÔNG gọi lại load API ở đây nữa
    _checkUserActive();
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(context),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCourses();
          _loadMentor();
          _loadCurrentUser();
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
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        '/listcourse',
                        arguments: value.trim(),
                      );
                    }
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
                        return EmptyStateWidget(
                          icon: Icons.cloud_off_rounded,
                          title: 'Không tải được danh sách giảng viên',
                          message: state.message,
                          isError: true,
                          actionLabel: 'Thử lại',
                          onAction: () => context.read<MentorsBloc>().add(
                            RefreshMentorsEvent(),
                          ),
                        );
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
                              return EmptyStateWidget(
                                icon: Icons.school_outlined,
                                title: 'Chưa có khoá học nào',
                                message: categoryState is CategoryLoaded &&
                                        categoryState.selectedId != null
                                    ? 'Danh mục này chưa có khoá học. Thử chọn danh mục khác.'
                                    : 'Các khoá học mới sẽ xuất hiện ở đây.',
                                actionLabel: 'Làm mới',
                                onAction: () {
                                  context
                                      .read<CategoryCubit>()
                                      .selectCategory(null);
                                  _loadCourses();
                                },
                              );
                            }

                            return ListCoursesWidget(
                              courses: list,
                              userUid:
                                  context.read<AuthCubit>().state.userId ?? '',
                            );
                          } else if (courseState is CourseError) {
                            return EmptyStateWidget(
                              icon: Icons.cloud_off_rounded,
                              title: 'Không tải được danh sách khoá học',
                              message: courseState.message,
                              isError: true,
                              actionLabel: 'Thử lại',
                              onAction: _loadCourses,
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
