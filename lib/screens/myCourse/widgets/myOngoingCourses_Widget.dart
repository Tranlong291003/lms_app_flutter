import 'package:flutter/material.dart';
import 'package:lms/screens/myCourse/widgets/CourseCard_Widget.dart';

class MyOngoingCoursesScreen extends StatelessWidget {
  final bool showCircular;

  const MyOngoingCoursesScreen({super.key, required this.showCircular});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> courses = [
      {
        "title": "Intro to UI/UX Design",
        "duration": "2 giờ 30 phút",
        "completed": 93,
        "total": 124,
        "progressColor": Colors.pink,
        "thumbnail": "https://via.placeholder.com/80x80.png?text=UIUX",
      },
      {
        "title": "Wordpress Website Devssssssssssssss",
        "duration": "3 giờ 15 phút",
        "completed": 73,
        "total": 146,
        "progressColor": Colors.orange,
        "thumbnail": "https://via.placeholder.com/80x80.png?text=WP",
      },
      {
        "title": "3D Blender and UI/UX",
        "duration": "2 giờ 48 phút",
        "completed": 30,
        "total": 119,
        "progressColor": Colors.teal,
        "thumbnail": "https://via.placeholder.com/80x80.png?text=3D",
      },
      {
        "title": "Learn UX User Persona",
        "duration": "2 giờ 35 phút",
        "completed": 82,
        "total": 137,
        "progressColor": Colors.amber,
        "thumbnail": "https://via.placeholder.com/80x80.png?text=UX",
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final course = courses[index];
        final double percent = course["completed"] / course["total"];

        return CourseCard(
          thumbnail: course["thumbnail"],
          title: course["title"],
          duration: course["duration"],
          progressValue: percent,
          progressColor: course["progressColor"],
          progressText: "${course["completed"]}/${course["total"]} bài",
          showCircular: showCircular,
        );
      },
    );
  }
}
