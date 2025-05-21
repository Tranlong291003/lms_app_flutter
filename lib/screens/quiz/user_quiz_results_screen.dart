import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/quiz/quiz_cubit.dart';
import 'package:lms/repositories/quiz_repository.dart';
import 'package:lms/services/quiz_service.dart';

class UserQuizResultsScreen extends StatelessWidget {
  final String userUid;
  const UserQuizResultsScreen({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create:
          (_) =>
              QuizResultListCubit(QuizRepository(QuizService()))
                ..fetchUserQuizResults(userUid),
      child: Scaffold(
        body: BlocBuilder<QuizResultListCubit, QuizResultListState>(
          builder: (context, state) {
            if (state is QuizResultListLoading) {
              return const Center(child: LoadingIndicator());
            }
            if (state is QuizResultListError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: colorScheme.error),
                ),
              );
            }
            if (state is QuizResultListLoaded) {
              final results = state.results;
              if (results.isEmpty) {
                return Center(
                  child: Text(
                    'Bạn chưa làm bài kiểm tra nào.',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final r = results[index];
                  final bool isPassed = r.passed;
                  final String title =
                      (r.title).trim().isNotEmpty ? r.title : 'Bài kiểm tra';
                  final DateTime? submittedAt = r.submittedAt;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    color: theme.cardColor,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: isPassed ? Colors.green : Colors.red,
                        child: Text(
                          r.score.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      title: Text(
                        title,
                        style: theme.textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (submittedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 2),
                              child: Text(
                                'Ngày làm: ${_formatDateTime(submittedAt)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              isPassed ? 'Trạng thái: Đậu' : 'Trạng thái: Rớt',
                              style: TextStyle(
                                color: isPassed ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.quizResultDetail,
                          arguments: {'resultId': r.resultId},
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
