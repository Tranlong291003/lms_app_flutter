import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/models/courses/courses_model.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual bookmarked courses from state management
    final List<Course> bookmarkedCourses = [
      Course(
        courseId: 1,
        instructorUid: 'instructor1',
        categoryId: 1,
        title: 'Lập trình Flutter cơ bản đến nâng cao',
        price: 1000000,
        discountPrice: 800000,
        thumbnailUrl: '/images/courses/flutter.jpg',
        categoryName: 'Mobile',
        level: 'Cơ bản',
        rating: 4.5,
        enrollCount: 1000,
        status: 'active',
        updatedAt: DateTime.now(),
        instructorName: 'Nguyễn Văn A',
      ),
      Course(
        courseId: 2,
        instructorUid: 'instructor2',
        categoryId: 2,
        title: 'Lập trình Backend với Node.js',
        price: 1200000,
        discountPrice: 900000,
        thumbnailUrl: '/images/courses/nodejs.jpg',
        categoryName: 'Backend',
        level: 'Trung cấp',
        rating: 4.8,
        enrollCount: 800,
        status: 'active',
        updatedAt: DateTime.now(),
        instructorName: 'Trần Văn B',
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Khóa học đã lưu',
        showBack: true,
        showSearch: true,
        showMenu: true,
        menuItems: [
          PopupMenuItem(
            value: 'sort',
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Sắp xếp'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'filter',
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Lọc'),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) {
          // TODO: Handle menu selection
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            bookmarkedCourses.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có khóa học nào được lưu',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          // TODO: Navigate to course list
                        },
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('Tìm khóa học'),
                      ),
                    ],
                  ),
                )
                : ListCoursesWidget(courses: bookmarkedCourses),
      ),
    );
  }
}
