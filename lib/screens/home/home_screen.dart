import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/screens/home/appBar_widget.dart';
import 'package:lms/screens/home/discountSlider_widget.dart';
import 'package:lms/screens/home/topMentors_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Lấy uid của user hiện tại và gọi API lấy thông tin user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<UserBloc>().add(GetUserByUidEvent(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(context, 'title'),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SearchBarWidget(),
                    DiscountSlider(),
                    const SizedBox(height: 10),
                    SectionHeader(
                      title: "Danh sách giáo viên",
                      onTap: () {
                        Navigator.pushNamed(context, '/listmentor');
                      },
                    ),
                    const SizedBox(height: 10),
                    TopMentors(),
                    const SizedBox(height: 10),
                    SectionHeader(
                      title: "Danh sách khoá học",
                      onTap: () {
                        Navigator.pushNamed(context, '/listcourse');
                      },
                    ),
                    const SizedBox(height: 10),
                    CourseCategoryWidget(),
                    ListCoursesWidget(courses: sampleCourses),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionHeader({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        InkWell(
          onTap: onTap,
          child: const Text(
            "Xem tất cả",
            style: TextStyle(
              color: Color(0xFF2F56DD),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
