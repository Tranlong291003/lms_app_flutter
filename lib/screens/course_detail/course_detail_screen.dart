import 'package:flutter/material.dart';
import 'package:lms/screens/course_detail/course_app_bar.dart';
import 'package:lms/screens/course_detail/course_stats_section.dart';
import 'package:lms/screens/course_detail/course_tab_view.dart';
import 'package:lms/screens/course_detail/course_title.dart';
import 'package:lms/screens/course_detail/enroll_button.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: const [
          CourseAppBar(),
          SliverToBoxAdapter(child: _CourseBody()),
        ],
      ),
      bottomNavigationBar: const SafeArea(
        minimum: EdgeInsets.all(20),
        child: EnrollButton(),
      ),
    );
  }
}

class _CourseBody extends StatelessWidget {
  const _CourseBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CourseTitle(),
          SizedBox(height: 16),
          CourseStatsSection(),
          SizedBox(height: 24),
          CourseTabView(),
        ],
      ),
    );
  }
}
