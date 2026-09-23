import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/services/course_service.dart';

class LessonsTab extends StatefulWidget {
  final int courseId;
  const LessonsTab({super.key, required this.courseId});

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  @override
  void initState() {
    super.initState();
    // Trước đây `loadLessons` được gọi thẳng trong `build()`: mỗi lần widget
    // dựng lại (đổi tab, mở bàn phím, đổi theme, cha setState…) lại bắn thêm
    // một request và emit `LessonsLoading` → gọi lại `build` → vòng lặp gọi API
    // liên tục. Chuyển sang `initState` để mỗi lần vào tab chỉ gọi một lần.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  void _load() {
    final userUid = context.read<AuthCubit>().state.userId ?? '';
    context.read<LessonsCubit>().loadLessons(
      courseId: widget.courseId,
      userUid: userUid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonsCubit, LessonsState>(
      builder: (context, state) {
        if (state is LessonsLoading) {
          return const Center(child: LoadingIndicator());
        }
        if (state is LessonsError) {
          return EmptyStateWidget(
            icon: Icons.cloud_off_rounded,
            title: 'Không tải được danh sách bài học',
            message: state.message,
            isError: true,
            actionLabel: 'Thử lại',
            onAction: _load,
          );
        }
        if (state is LessonsLoaded) {
          return _LessonsList(
            lessons: state.lessons,
            courseId: widget.courseId,
          );
        }
        return const Center(child: LoadingIndicator());
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
      return const EmptyStateWidget(
        icon: Icons.play_lesson_outlined,
        title: 'Chưa có bài học nào',
        message: 'Giảng viên chưa đăng bài giảng cho khoá học này.',
      );
    }

    final userUid = context.read<AuthCubit>().state.userId ?? '';
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return FutureBuilder<bool>(
      future: CourseService().checkEnrollment(
        userUid: userUid,
        courseId: courseId,
      ),
      builder: (context, snapshot) {
        final isEnrolled = snapshot.data == true;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
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
              canTap = true;
              iconData = Icons.check_circle;
              iconColor = AppColors.of(context).success;
              trailingIcon = Icon(
                Icons.check_circle,
                color: iconColor,
                size: 28,
              );
            } else if (index == 0 || prevCompleted) {
              // Được phép học (bài 1 hoặc bài trước đã hoàn thành)
              canTap = true;
              iconData = Icons.lock_open;
              iconColor = scheme.primary;
              trailingIcon = Icon(
                Icons.play_circle_fill,
                color: scheme.primary,
                size: 32,
              );
            } else {
              // Chưa được phép học
              canTap = false;
              iconData = Icons.lock_outline;
              iconColor = scheme.onSurfaceVariant;
              trailingIcon = Icon(
                Icons.lock,
                color: scheme.onSurfaceVariant,
                size: 28,
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              color: scheme.surface,
              child: InkWell(
                borderRadius: AppRadius.borderLg,
                onTap:
                    canTap
                        ? () async {
                          final ctx = context;
                          await Navigator.pushNamed(
                            ctx,
                            AppRouter.lessonDetail,
                            arguments: {
                              'lessonId': lesson.lessonId,
                              'courseId': lesson.courseId,
                            },
                          );
                          // Sau khi quay lại, refresh lại danh sách bài học để
                          // cập nhật trạng thái hoàn thành và mở khoá bài kế.
                          if (!ctx.mounted) return;
                          final userUid =
                              ctx.read<AuthCubit>().state.userId ?? '';
                          ctx.read<LessonsCubit>().loadLessons(
                            courseId: courseId,
                            userUid: userUid,
                          );
                        }
                        : () {
                          // Nói rõ VÌ SAO bài bị khoá — trước đây cả hai
                          // trường hợp dùng chung một snackbar mặc định của
                          // Material nên nhìn không thuộc về app.
                          if (!isEnrolled) {
                            CustomSnackBar.showInfo(
                              context: context,
                              message:
                                  'Bạn cần đăng ký khoá học để học các bài giảng.',
                            );
                          } else {
                            CustomSnackBar.showInfo(
                              context: context,
                              message:
                                  'Hoàn thành bài trước để mở khoá bài này.',
                            );
                          }
                        },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(iconData, color: iconColor, size: 24),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color:
                                    canTap
                                        ? scheme.onSurface
                                        : scheme.onSurfaceVariant,
                              ),
                            ),
                            if ((lesson.videoDuration ?? '').isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                lesson.videoDuration!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      trailingIcon,
                    ],
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
