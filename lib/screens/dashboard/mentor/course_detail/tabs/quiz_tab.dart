import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/quiz/quiz_cubit.dart';
import 'package:lms/cubits/quiz/quiz_state.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/screens/quiz/quiz_question_list_screen.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class QuizTab extends StatelessWidget {
  final int courseId;
  const QuizTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final scaffoldContext = context;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Stack(
      children: [
        BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (state.status == QuizStatus.error) {
              return Center(child: Text('Lỗi: \\${state.errorMessage}'));
            }
            final quizList = state.quizzesByCourseId;
            if (quizList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.quiz_outlined,
                      size: 56,
                      color: colors.onSurfaceVariant.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài kiểm tra nào',
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Các bài kiểm tra sẽ sớm được cập nhật',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<QuizCubit>().getQuizzesByCourseId(courseId);
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: quizList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final quiz = quizList[index];
                  return Slidable(
                    key: ValueKey(quiz.quizId),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.32,
                      children: [
                        SlidableAction(
                          onPressed:
                              (_) => _showQuizDialog(
                                scaffoldContext,
                                quiz: quiz,
                                courseId: courseId,
                              ),
                          backgroundColor: colors.primary,
                          foregroundColor: Colors.white,
                          icon: Icons.edit,
                          label: '',
                          borderRadius: BorderRadius.circular(12),
                        ),
                        SlidableAction(
                          onPressed: (_) async {
                            final parentContext = scaffoldContext;
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text('Xác nhận xoá'),
                                    content: const Text(
                                      'Bạn có chắc muốn xoá quiz này?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                        child: const Text('Huỷ'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, true),
                                        child: const Text('Xoá'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              final adminUid =
                                  FirebaseAuth.instance.currentUser?.uid ?? '';
                              final result = await parentContext
                                  .read<QuizCubit>()
                                  .deleteQuiz(quiz.quizId, courseId, {
                                    "uid": adminUid,
                                  });
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () {
                                  if (result && parentContext.mounted) {
                                    CustomSnackBar.showSuccess(
                                      context: parentContext,
                                      message: 'Xoá quiz thành công!',
                                    );
                                  } else if (!result && parentContext.mounted) {
                                    CustomSnackBar.showError(
                                      context: parentContext,
                                      message: 'Xoá quiz thất bại!',
                                    );
                                  }
                                },
                              );
                            }
                          },
                          backgroundColor: colors.error,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: '',
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    child: _QuizCard(
                      title: quiz.title,
                      type: quiz.displayType,
                      timeLimit: quiz.timeLimit,
                      passingScore: 0,
                      questionCount: quiz.totalQuestions,
                      averageScore: quiz.averageScore,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    QuizQuestionListScreen(quizId: quiz.quizId),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed:
                () => _showQuizDialog(scaffoldContext, courseId: courseId),
            tooltip: 'Tạo quiz mới',
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  void _showQuizDialog(
    BuildContext parentContext, {
    QuizModel? quiz,
    required int courseId,
  }) async {
    final isEdit = quiz != null;
    final titleController = TextEditingController(text: quiz?.title ?? '');
    final timeLimitOptions = [15, 30, 60, 90];
    final attemptLimitOptions = [1, 2, 3, 4, 5];
    int selectedTimeLimit = quiz?.timeLimit ?? 60;
    int selectedAttemptLimit = quiz?.attemptLimit ?? 3;
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    final result = await showDialog<bool>(
      context: parentContext,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setState) => AlertDialog(
                  title: Text(isEdit ? 'Sửa quiz' : 'Tạo quiz mới'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Tên quiz',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: selectedTimeLimit,
                          items:
                              timeLimitOptions
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text('$v phút'),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) =>
                                  setState(() => selectedTimeLimit = v ?? 60),
                          decoration: const InputDecoration(
                            labelText: 'Thời gian',
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          value: selectedAttemptLimit,
                          items:
                              attemptLimitOptions
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text('$v lần'),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) =>
                                  setState(() => selectedAttemptLimit = v ?? 3),
                          decoration: const InputDecoration(
                            labelText: 'Số lần làm',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Huỷ'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final data = {
                          if (!isEdit) 'course_id': courseId,
                          'title': title,
                          'type': 'trac_nghiem',
                          'time_limit': selectedTimeLimit,
                          'attempt_limit': selectedAttemptLimit,
                          'uid': adminUid,
                        };
                        final cubit = parentContext.read<QuizCubit>();
                        bool success = false;
                        if (isEdit) {
                          success = await cubit.updateQuiz(
                            quiz.quizId,
                            data,
                            courseId,
                          );
                        } else {
                          success = await cubit.createQuiz(data, courseId);
                        }
                        Navigator.pop(ctx, success);
                      },
                      child: Text(isEdit ? 'Cập nhật' : 'Tạo'),
                    ),
                  ],
                ),
          ),
    );

    // Show SnackBar sau khi dialog đã đóng
    if (result == true) {
      CustomSnackBar.showSuccess(
        context: parentContext,
        message: isEdit ? 'Cập nhật quiz thành công!' : 'Tạo quiz thành công!',
      );
    } else if (result == false && isEdit) {
      CustomSnackBar.showError(
        context: parentContext,
        message: 'Cập nhật quiz thất bại!',
      );
    } else if (result == false && !isEdit) {
      CustomSnackBar.showError(
        context: parentContext,
        message: 'Tạo quiz thất bại!',
      );
    }
  }
}

class _QuizCard extends StatelessWidget {
  final String title;
  final String type;
  final int timeLimit;
  final int passingScore;
  final int questionCount;
  final double averageScore;
  final VoidCallback onTap;

  const _QuizCard({
    required this.title,
    required this.type,
    required this.timeLimit,
    required this.passingScore,
    required this.questionCount,
    required this.averageScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section with quiz type badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withOpacity(0.6),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$questionCount câu hỏi · Điểm đạt: $passingScore% · TB: ${averageScore.toStringAsFixed(1)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Quiz type badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: colors.outlineVariant.withOpacity(0.2)),

          // Quiz info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _QuizInfoItem(
                  icon: Icons.timer,
                  label: 'Thời gian',
                  value: '$timeLimit phút',
                  color: colors.primary,
                ),
                const SizedBox(width: 16),
                _QuizInfoItem(
                  icon: Icons.help_outline,
                  label: 'Số câu hỏi',
                  value: '$questionCount câu',
                  color: colors.secondary,
                ),
                const SizedBox(width: 16),
                _QuizInfoItem(
                  icon: Icons.check_circle_outline,
                  label: 'Điểm đạt',
                  value: '$passingScore%',
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: onTap,
                child: const Text('Xem chi tiết'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuizInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
