import 'package:flutter/material.dart';
import 'package:lms/screens/myCourse/widgets/CourseCard_Widget.dart';

class MyCompletedCoursesScreen extends StatelessWidget {
  final bool showCircular;

  const MyCompletedCoursesScreen({super.key, required this.showCircular});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> courses = [
      {
        "title": "3D Design Illustration",
        "duration": "2 giờ 25 phút",
        "completed": 178,
        "total": 178,
        "thumbnail": "https://via.placeholder.com/100x100.png?text=3D",
      },
      {
        "title": "CRM Management for Dev",
        "duration": "3 giờ 20 phút",
        "completed": 129,
        "total": 129,
        "thumbnail": "https://via.placeholder.com/100x100.png?text=CRM",
      },
      {
        "title": "Flutter Mobile Apps",
        "duration": "4 giờ 50 phút",
        "completed": 285,
        "total": 285,
        "thumbnail": "https://via.placeholder.com/100x100.png?text=Flutter",
      },
      {
        "title": "3D Icons Set Blender",
        "duration": "2 giờ 45 phút",
        "completed": 256,
        "total": 256,
        "thumbnail": "https://via.placeholder.com/100x100.png?text=Icon",
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
          progressColor: const Color(0xFF2F56DD), // màu xanh dương mặc định
          progressText: "${course["completed"]}/${course["total"]} bài",
          showCircular: showCircular,
        );
      },
    );
  }
}
