import 'package:flutter/material.dart';
import 'package:lms/screens/myCourse/widgets/myCompletedCourses_Widget.dart';
import 'package:lms/screens/myCourse/widgets/myOngoingCourses_Widget.dart';

class MyCourseScreen extends StatefulWidget {
  const MyCourseScreen({super.key});

  @override
  State<MyCourseScreen> createState() => _MyCourseScreenState();
}

class _MyCourseScreenState extends State<MyCourseScreen> {
  bool showCircular = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F56DD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.e_mobiledata,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Khoá học của tôi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              tooltip: 'Tuỳ chọn hiển thị',
              onSelected: (value) {
                setState(() {
                  showCircular = value == 'circle';
                });
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'linear',
                      child: Icon(
                        Icons.linear_scale,
                        color: !showCircular ? Colors.blue : Colors.black54,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'circle',
                      child: Icon(
                        Icons.donut_large,
                        color: showCircular ? Colors.blue : Colors.black54,
                      ),
                    ),
                  ],
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF2F56DD),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF2F56DD),
            tabs: [Tab(text: 'Đang học'), Tab(text: 'Đã hoàn thành')],
          ),
        ),
        body: TabBarView(
          children: [
            MyOngoingCoursesScreen(showCircular: showCircular),
            MyCompletedCoursesScreen(showCircular: showCircular),
          ],
        ),
      ),
    );
  }
}
