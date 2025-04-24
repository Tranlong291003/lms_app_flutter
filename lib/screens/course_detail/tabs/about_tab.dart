import 'package:flutter/material.dart';

import '../shared/expandable_description.dart';

class AboutTab extends StatelessWidget {
  const AboutTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Giảng viên',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage('assets/images/mentor.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Jonathan Williams',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Chuyên gia thiết kế tại Google'),
                ],
              ),
              const Spacer(),
              const Icon(Icons.chat_bubble_outline, color: Colors.blue),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Giới thiệu khoá học',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const ExpandableDescription(),
          const SizedBox(height: 24),
          const Text(
            'Công cụ sử dụng',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.network(
                'https://blog.greggant.com/images/posts/2019-04-25-figma/Figma.png',
                width: 20,
              ),
              const SizedBox(width: 8),
              const Text('Figma'),
            ],
          ),
        ],
      ),
    );
  }
}
