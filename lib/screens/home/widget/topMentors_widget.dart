import 'package:flutter/material.dart';

class TopMentors extends StatelessWidget {
  const TopMentors({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fakeMentors = [
      {"name": "Anh Dũng", "imageUrl": "https://i.pravatar.cc/150?img=1"},
      {"name": "Bích Ngọc", "imageUrl": "https://i.pravatar.cc/150?img=2"},
      {"name": "Thảo Linh", "imageUrl": "https://i.pravatar.cc/150?img=3"},
      {"name": "Minh Quân", "imageUrl": "https://i.pravatar.cc/150?img=4"},
      {"name": "Thanh Hà", "imageUrl": "https://i.pravatar.cc/150?img=5"},
      {"name": "Hoàng Nam", "imageUrl": "https://i.pravatar.cc/150?img=6"},
      {"name": "Lan Anh", "imageUrl": "https://i.pravatar.cc/150?img=7"},
      {"name": "Tuấn Kiệt", "imageUrl": "https://i.pravatar.cc/150?img=8"},
      {"name": "Mai Phương", "imageUrl": "https://i.pravatar.cc/150?img=9"},
      {"name": "Đức Huy", "imageUrl": "https://i.pravatar.cc/150?img=10"},
    ];

    return Column(
      children: [
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: fakeMentors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final mentor = fakeMentors[index];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(mentor["imageUrl"]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mentor["name"],
                    style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
