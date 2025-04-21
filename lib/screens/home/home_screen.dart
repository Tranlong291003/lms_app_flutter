import 'package:flutter/material.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';
import 'package:lms/screens/home/widget/appBar_widget.dart';
import 'package:lms/screens/home/widget/discountSlider_widget.dart';
import 'package:lms/screens/home/widget/topMentors_widget.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
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
                SizedBox(height: 10),
                SectionHeader(
                  title: "Danh sách giáo viên",
                  onTap: () {
                    Navigator.pushNamed(context, '/listmentor');
                  },
                ),
                SizedBox(height: 10),
                TopMentors(),
                SizedBox(height: 10),
                SectionHeader(
                  title: "Danh sách khoá học",
                  onTap: () {
                    Navigator.pushNamed(context, '/listcourse');
                  },
                ),
                SizedBox(height: 10),
                CourseCategoryWidget(),
                ListCoursesWidget(courses: sampleCourses),
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
