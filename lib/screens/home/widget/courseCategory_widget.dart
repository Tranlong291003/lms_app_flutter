import 'package:flutter/material.dart';

class CourseCategory extends StatelessWidget {
  const CourseCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"label": "Tất cả", "emoji": "🔥", "isSelected": true},
      {"label": "Thiết kế 3D", "emoji": "💡"},
      {"label": "Kinh doanh", "emoji": "💰"},
      {"label": "Marketing", "emoji": "📊"},
      {"label": "Lập trình", "emoji": "👨‍💻"},
      {"label": "Âm nhạc", "emoji": "🎵"},
      {"label": "Trí tuệ nhân tạo", "emoji": "🤖"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề và nút xem tất cả
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Khoá học phổ biến",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
            Text(
              "Xem tất cả",
              style: TextStyle(
                color: Color(0xFF2F56DD),
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Danh sách chip cuộn ngang
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final bool isSelected = category["isSelected"] == true;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF2F56DD) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2F56DD),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  "${category["emoji"]} ${category["label"]}",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: isSelected ? Colors.white : const Color(0xFF2F56DD),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
