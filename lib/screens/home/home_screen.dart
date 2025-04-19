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
                TopMentors(),
                CourseCategory(),
                ListCoursesList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
