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
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/screens/home/appBar_widget.dart';
import 'package:lms/screens/home/discountSlider_widget.dart';
import 'package:lms/screens/home/topMentors_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final List<Map<String, dynamic>> sampleCourses = List.generate(10, (index) {
    return {
      "title": "Khoá học Flutter nâng cao số ${index + 1}",
      "thumbnail_url":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIviTPCD7epj8fyQGlF5uMqKIE20C_JuULQw&s",
      "category": ["Lập trình", "Thiết kế", "Marketing"][index % 3],
      "price": 500000 + (index * 10000),
      "discount_price": index % 2 == 0 ? 400000 + (index * 8000) : null,
      "language": index % 2 == 0 ? "Tiếng Việt" : "Tiếng Anh",
      "level": ["Cơ bản", "Trung cấp", "Nâng cao"][index % 3],
    };
  });

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMentor();
  }

  void _loadCurrentUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<UserBloc>().add(GetUserByUidEvent(uid));
    }
  }

  void _loadMentor() {
    context.read<MentorsBloc>().add(GetAllMentorsEvent());
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
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBarHome(context, 'Home'),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            // return const LoadingIndicator();
          } else if (state is UserError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(),
                  const SizedBox(height: 5),
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
                  const SizedBox(height: 5),
                  _buildSection(
                    title: 'Danh sách khoá học',
                    onTap: () => Navigator.pushNamed(context, '/listcourse'),
                    child: Column(
                      children: [
                        CourseCategoryWidget(),
                        const SizedBox(height: 5),
                        ListCoursesWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
