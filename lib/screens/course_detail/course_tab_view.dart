import 'package:flutter/material.dart';
import 'package:lms/screens/course_detail/tabs/about_tab.dart';
import 'package:lms/screens/course_detail/tabs/lessons_tab.dart';
import 'package:lms/screens/course_detail/tabs/reviews_tab.dart';

class CourseTabView extends StatelessWidget {
  final String description;
  final String instructorName;
  final String? instructorAvatarUrl;
  final String? instructorBio;
  final int courseId;

  const CourseTabView({
    super.key,
    required this.description,
    required this.instructorName,
    required this.courseId,
    this.instructorAvatarUrl,
    this.instructorBio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Phần TabBar: chỉ border trên/trái/phải, bo góc trên ─────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.18),
                  width: 1.2,
                ),
                left: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.18),
                  width: 1.2,
                ),
                right: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.18),
                  width: 1.2,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.onSurface.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              // cái Border trên tab đang chọn
              indicator: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.primary, width: 3.2),
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                0.6,
              ),
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Giới thiệu'),
                Tab(text: 'Bài học'),
                Tab(text: 'Đánh giá'),
              ],
            ),
          ),

          // ── Phần nội dung ────────────────────────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: TabBarView(
              children: [
                AboutTab(
                  description: description,
                  instructorName: instructorName,
                  instructorAvatarUrl: instructorAvatarUrl,
                  instructorBio: instructorBio,
                ),
                LessonsTab(courseId: courseId),
                ReviewsTab(courseId: courseId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
