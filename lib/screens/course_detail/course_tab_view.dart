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
  final String language;
  final String tags;
  final String level;
  final String instructorUid;
  const CourseTabView({
    super.key,
    required this.description,
    required this.instructorName,
    required this.courseId,
    required this.language,
    required this.tags,
    required this.level,
    this.instructorAvatarUrl,
    this.instructorBio,
    required this.instructorUid,
  });

  /// Chiều cao vùng nội dung tab.
  ///
  /// Không phải hằng số 50% như trước: tính theo chiều cao thật của màn hình,
  /// trừ đi phần đã bị ảnh bìa + tiêu đề khoá học + thanh thông số chiếm mất,
  /// và vẫn giữ một mức tối thiểu để tab ngắn không bị bóp lại.
  double _contentHeight(BuildContext context) {
    final media = MediaQuery.of(context);
    // ảnh bìa (khoảng 220) + tiêu đề/thông số (khoảng 180) + thanh công cụ
    const occupiedByHeader = 400.0;
    final available = media.size.height - media.padding.vertical - occupiedByHeader;
    return available.clamp(320.0, media.size.height * 0.75);
  }

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
          //
          // Widget này nằm trong CustomScrollView nên chiều cao KHÔNG bị chặn —
          // dùng `Expanded` ở đây sẽ ném lỗi layout. Vì vậy vẫn cần một chiều
          // cao xác định, nhưng tính theo phần màn hình còn lại (trừ thanh công
          // cụ và phần đầu trang) thay vì cố định 50%.
          SizedBox(
            height: _contentHeight(context),
            child: TabBarView(
              children: [
                AboutTab(
                  description: description,
                  instructorName: instructorName,
                  instructorAvatarUrl: instructorAvatarUrl,
                  instructorBio: instructorBio,
                  instructorUid: instructorUid,
                  language: language,
                  tags: tags,
                  level: level,
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
