import 'package:flutter/material.dart';

class CourseAppBar extends StatelessWidget {
  const CourseAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      flexibleSpace: const FlexibleSpaceBar(
        background: Image(
          image: NetworkImage(
            'https://vtiacademy.edu.vn/upload/images/cau-lac-bo/thiet-ke-ui-ux-la-gi-tai-sao-nghe-ux-ui-ngay-cang-hot.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
