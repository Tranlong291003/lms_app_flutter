import 'package:flutter/material.dart';
import 'package:lms/apps/utils/courseCategory_widget.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';

class ListCoursescreen extends StatelessWidget {
  const ListCoursescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sampleCourses = List.generate(50, (index) {
      return {
        "title": "Khoá học Flutter nâng cao số ${index + 1}",
        "thumbnail_url":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRIviTPCD7epj8fyQGlF5uMqKIE20C_JuULQw&s",
        "category": ["Lập trình", "Thiết kế", "Marketing"][index % 3],
        "price": 500000 + (index * 10000),
        "discount_price": index % 2 == 0 ? 400000 + (index * 8000) : null,
        "language": index % 2 == 0 ? "Tiếng Việt" : "Tiếng Anh",
        "level": ["Cơ bản", "Trung cấp", "Nâng cao"][index % 3],
      };
    });

    return Scaffold(
      appBar: CustomAppBar(
        showBack: true,
        showSearch: true,
        showMenu: true,
        title: 'Danh sách khoá học',
        onSearchChanged: (value) {
          // Gọi API tìm kiếm ở đây
          // Có thể debounce bằng Bloc hoặc timer
          print('Đang tìm kiếm: $value');
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [CourseCategoryWidget(), ListCoursesWidget()],
          ),
        ),
      ),
    );
  }
}
