import 'package:flutter/material.dart';
import 'package:lms/screens/course_detail/shared/icon_text.dart';

class CourseStatsSection extends StatelessWidget {
  const CourseStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _chip(context, 'Thiết kế UI/UX'),
            const SizedBox(width: 8),
            _starRating(),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: const [
            IconText(icon: Icons.people, text: '9.839 học viên'),
            IconText(icon: Icons.timer, text: '2.5 giờ học'),
            IconText(icon: Icons.verified, text: 'Có chứng chỉ'),
          ],
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color:
          Theme.of(context).brightness == Brightness.light
              ? Colors.blue[50]
              : Colors.blue[900],
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12)),
  );

  Widget _starRating() => Row(
    children: const [
      Icon(Icons.star, size: 18, color: Colors.amber),
      SizedBox(width: 4),
      Text('4.8 (4.479 đánh giá)'),
    ],
  );
}
