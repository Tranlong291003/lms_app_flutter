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
    _userService = UserService(token: FirebaseAuth.instance.currentUser?.uid);
    if (_isFirstLoad) {
      _loadMentor();
      _loadCurrentUser();
      _loadCourses();
      _checkUserActive();
      context.read<CategoryCubit>().fetchAllCategory();
      _isFirstLoad = false;
    }
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

    // Gọi logoutWithContext để xử lý đăng xuất
    await context.read<AuthCubit>().logout();
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
    // KHÔNG gọi lại load API ở đây nữa
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
          _loadMentor();
          _loadCurrentUser();
          context.read<MentorsBloc>().add(RefreshMentorsEvent());
          context.read<UserBloc>().add(RefreshUserEvent());
          context.read<CategoryCubit>().refreshCategories();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroPanel(context),
                const SizedBox(height: 18),
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
                const SizedBox(height: 8),
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

  Widget _buildHeroPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
            colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.22),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -28,
            child: Icon(
              Icons.auto_stories_rounded,
              color: Colors.white.withOpacity(0.14),
              size: 120,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: const Text(
                  'Lộ trình học cá nhân hoá',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nâng cấp kỹ năng của bạn mỗi ngày',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Khám phá khóa học, mentor và quiz phù hợp để học nhanh hơn.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.86),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HeroMetric(icon: Icons.play_circle, label: 'Video bài học'),
                  _HeroMetric(icon: Icons.people_alt, label: 'Mentor 1:1'),
                  _HeroMetric(icon: Icons.quiz, label: 'Quiz luyện tập'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton.icon(
              onPressed: onTap,
              icon: const Text('Xem tất cả'),
              label: const Icon(Icons.arrow_forward_rounded, size: 18),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
