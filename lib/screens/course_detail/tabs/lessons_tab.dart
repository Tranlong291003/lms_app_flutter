import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubit/lessons/lessons_cubit.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/services/course_service.dart';

class LessonsTab extends StatelessWidget {
  final int courseId;
  const LessonsTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';

    return BlocProvider(
      create:
          (_) =>
              LessonsCubit()..loadLessons(courseId: courseId, userUid: userUid),
      child: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (context, state) {
          if (state is LessonsLoading) {
            return const Center(child: LoadingIndicator());
          }
          if (state is LessonsError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          if (state is LessonsLoaded) {
            return _LessonsList(lessons: state.lessons);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _LessonsList extends StatelessWidget {
  final List<Lesson> lessons;
  const _LessonsList({required this.lessons});

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Text(
            'Chưa có bài học nào cho khoá học này',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';

    return FutureBuilder<bool>(
      future: CourseService().checkEnrollment(
        userUid: userUid,
        courseId: lessons.first.courseId,
      ),
      builder: (context, snapshot) {
        final isEnrolled = snapshot.data == true;
        final theme = Theme.of(context);

        // ❗️Bài đầu tiên chưa hoàn thành
        int firstUnfinishedIndex = lessons.indexWhere(
          (l) => !l.isPreview,
        ); // SỬA
        if (firstUnfinishedIndex == -1) firstUnfinishedIndex = lessons.length;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];

            bool isFirst = index == 0;
            bool isCompleted = lesson.isPreview; // SỬA
            bool isCurrent = index == firstUnfinishedIndex;
            bool isLocked = index > firstUnfinishedIndex;

            IconData iconData;
            Color iconColor;
            Widget? trailingIcon;
            bool canTap = false;

            if (!isEnrolled) {
              /// CHƯA đăng ký: chỉ cho xem bài đầu tiên (preview)
              if (isFirst) {
                iconData = Icons.lock_open;
                iconColor = theme.colorScheme.primary;
                trailingIcon = Icon(
                  Icons.play_circle_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
                canTap = true;
              } else {
                iconData = Icons.lock_outline;
                iconColor = theme.colorScheme.onSurface.withOpacity(0.5);
                trailingIcon = null;
                canTap = false;
              }
            } else {
              /// ĐÃ đăng ký
              if (isCompleted) {
                iconData = Icons.check_circle;
                iconColor = Colors.green;
                trailingIcon = Icon(
                  Icons.play_circle_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
                canTap = true;
              } else if (isCurrent) {
                iconData = Icons.play_circle_outline;
                iconColor = theme.colorScheme.primary;
                trailingIcon = Icon(
                  Icons.play_circle_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
                canTap = true;
              } else if (isLocked) {
                iconData = Icons.lock_outline;
                iconColor = theme.colorScheme.onSurface.withOpacity(0.5);
                trailingIcon = null;
                canTap = false;
              } else {
                // Trường hợp còn lại (chưa hoàn thành nhưng được phép xem)
                iconData = Icons.play_circle_outline;
                iconColor = theme.colorScheme.primary;
                trailingIcon = Icon(
                  Icons.play_circle_fill,
                  color: theme.colorScheme.primary,
                  size: 32,
                );
                canTap = true;
              }
            }

            return Opacity(
              opacity: canTap ? 1.0 : 0.4,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: theme.colorScheme.surface,
                child: InkWell(
                  onTap:
                      canTap
                          ? () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.lessonDetail,
                              arguments: lesson.lessonId,
                            );
                          }
                          : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(iconData, color: iconColor, size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lesson.videoDuration ?? '',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (trailingIcon != null) trailingIcon,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
