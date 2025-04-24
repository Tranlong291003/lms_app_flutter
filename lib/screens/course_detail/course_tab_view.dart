import 'package:flutter/material.dart';
import 'package:lms/screens/course_detail/tabs/about_tab.dart';
import 'package:lms/screens/course_detail/tabs/lessons_tab.dart';
import 'package:lms/screens/course_detail/tabs/reviews_tab.dart';

class CourseTabView extends StatelessWidget {
  const CourseTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: 'Giới thiệu'),
              Tab(text: 'Bài học'),
              Tab(text: 'Đánh giá'),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: const TabBarView(
              children: [AboutTab(), LessonsTab(), ReviewsTab()],
            ),
          ),
        ],
      ),
    );
  }
}
