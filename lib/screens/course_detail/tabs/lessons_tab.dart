import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/services/course_service.dart';

class LessonsTab extends StatelessWidget {
  final int courseId;
  const LessonsTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';
    final cubit = context.read<LessonsCubit>();

    // Load lessons when widget is built
    cubit.loadLessons(courseId: courseId, userUid: userUid);

    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        if (state is LessonsLoading) {
          return const Center(child: LoadingIndicator());
        }
        if (state is LessonsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => cubit.loadLessons(
                        courseId: courseId,
                        userUid: userUid,
                      ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        if (state is LessonsLoaded) {
          return _LessonsList(lessons: state.lessons, courseId: courseId);
        }
        return const SizedBox();
      },
    );
  }
}

class _LessonsList extends StatelessWidget {
  final List<Lesson> lessons;
  final int courseId;

  const _LessonsList({required this.lessons, required this.courseId});

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
    final theme = Theme.of(context);

    return FutureBuilder<bool>(
      future: CourseService().checkEnrollment(
        userUid: userUid,
        courseId: courseId,
      ),
      builder: (context, snapshot) {
        final isEnrolled = snapshot.data == true;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];

            // Khai báo biến trước khi sử dụng
            bool isLocked = false;
            bool canTap = false;
            IconData iconData = Icons.lock_open;
            Color iconColor = theme.colorScheme.primary;
            Widget? trailingIcon;

            // Xác định trạng thái bài học
            bool prevCompleted =
                index == 0 ? true : lessons[index - 1].isCompleted;
            bool isCurrentCompleted = lesson.isCompleted;
            if (isCurrentCompleted) {
              // Đã học xong
              isLocked = false;
              canTap = true;
              iconData = Icons.check_circle;
              iconColor = Colors.green;
              trailingIcon = Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              );
            } else if (index == 0 || prevCompleted) {
              // Được phép học (bài 1 hoặc bài trước đã hoàn thành)
              isLocked = false;
              canTap = true;
              iconData = Icons.lock_open;
              iconColor = theme.colorScheme.primary;
              trailingIcon = Icon(
                Icons.play_circle_fill,
                color: theme.colorScheme.primary,
                size: 32,
              );
            } else {
              // Chưa được phép học
              isLocked = true;
              canTap = false;
              iconData = Icons.lock_outline;
              iconColor = theme.colorScheme.onSurface.withOpacity(0.5);
              trailingIcon = Icon(
                Icons.lock,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 28,
              );
            }

            return Opacity(
              opacity: canTap ? 1.0 : 0.4,
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: theme.colorScheme.surface,
                child: InkWell(
                  onTap:
                      canTap
                          ? () async {
                            await Navigator.pushNamed(
                              context,
                              AppRouter.lessonDetail,
                              arguments: lesson.lessonId,
                            );
                            // Sau khi quay lại, refresh lại danh sách bài học
                            final user = FirebaseAuth.instance.currentUser;
                            final userUid = user?.uid ?? '';
                            context.read<LessonsCubit>().loadLessons(
                              courseId: courseId,
                              userUid: userUid,
                            );
                          }
                          : () {
                            if (!isEnrolled) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bạn cần đăng ký khoá học để học tiếp các bài sau!',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Hãy hoàn thành bài trước để mở khoá bài này!',
                                  ),
                                ),
                              );
                            }
                          },
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
                        trailingIcon,
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
