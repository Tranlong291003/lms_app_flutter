import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/screens/myCourse/my_completed_courses.dart';
import 'package:lms/screens/myCourse/my_ongoing_courses.dart';

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
        appBar: CustomAppBar(
          // Chỉ hiện nút back nếu bạn cần (ở đây không dùng)
          showBack: false,
          // Tiêu đề
          title: 'Khoá học của tôi',
          // Cho phép bật/tắt search
          showSearch: true,
          onSearchChanged: (query) {
            // TODO: xử lý tìm kiếm ở đây
          },
          // Cho phép menu 3 chấm
          showMenu: true,
          menuItems: [
            PopupMenuItem(
              value: 'linear',
              child: Row(
                children: [
                  Icon(
                    Icons.linear_scale,
                    color:
                        !showCircular
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  const Text('Dạng thanh tiến trình'),
                  const Spacer(),
                  if (!showCircular)
                    Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'circle',
              child: Row(
                children: [
                  Icon(
                    Icons.donut_large,
                    color:
                        showCircular
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  const Text('Dạng vòng tròn'),
                  const Spacer(),
                  if (showCircular)
                    Icon(
                      Icons.check_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ],
          onMenuSelected: (value) {
            setState(() {
              showCircular = value == 'circle';
            });
          },
          // TabBar bên dưới
          tabs: const [Tab(text: 'Đang học'), Tab(text: 'Đã hoàn thành')],
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
