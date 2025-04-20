import 'package:flutter/material.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/screens/home/widget/appBar_widget.dart';
import 'package:lms/screens/home/widget/courseCategory_widget.dart';
import 'package:lms/screens/home/widget/discountSlider_widget.dart';
import 'package:lms/screens/home/widget/listCourses_widget.dart';
import 'package:lms/screens/home/widget/topMentors_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHome(context, 'title'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SearchBarWidget(),
                DiscountSlider(),
                SizedBox(height: 5),
                SectionHeader(
                  title: "Danh sách giáo viên",
                  onTap: () {
                    Navigator.pushNamed(context, '/listmentor');
                  },
                ),
                SizedBox(height: 10),
                TopMentors(),
                SizedBox(height: 5),
                SectionHeader(
                  title: "Danh sách khoá học",
                  onTap: () {
                    Navigator.pushNamed(context, '/listcourse');
                  },
                ),
                SizedBox(height: 10),
                CourseCategory(),
                ListCoursesWidget(),
              ],
            ),
          ),
        ),
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
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        InkWell(
          onTap: onTap,
          child: const Text(
            "Xem tất cả",
            style: TextStyle(
              color: Color(0xFF2F56DD),
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }
}
