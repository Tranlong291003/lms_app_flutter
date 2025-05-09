import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:lms/cubit/category/category_cubit.dart';
import 'package:lms/cubit/category/category_state.dart';
import 'package:lms/cubit/courses/course_cubit.dart';
import 'package:lms/screens/home/appBar_widget.dart';
import 'package:lms/screens/home/discountSlider_widget.dart';
import 'package:lms/screens/home/topMentors_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    _loadMentor();
    _loadCurrentUser();
    context.read<CourseCubit>().loadCourses(status: 'true');
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBarHome(context, 'title'),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CourseCubit>().refreshCourses();
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
                SearchBarWidget(),
                DiscountSlider(),
                _buildSection(
                  title: 'Danh sách giảng viên',
                  onTap: () => Navigator.pushNamed(context, '/listmentor'),
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
                  onTap: () => Navigator.pushNamed(context, '/listcourse'),
                  child: Column(
                    children: [
                      CourseCategoryWidget(),
                      const SizedBox(height: 20),
                      BlocBuilder<CourseCubit, CourseState>(
                        builder: (context, courseState) {
                          if (courseState is CourseLoading) {
                            return const SizedBox(
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
                            final limitedList = list.take(10).toList();
                            return ListCoursesWidget(courses: limitedList);
                          } else if (courseState is CourseError) {
                            return const SizedBox(
                              child: Center(
                                child: Text('Không có khoá học nào tổn tại'),
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
