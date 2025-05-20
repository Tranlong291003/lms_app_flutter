import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/quiz/quiz_cubit.dart';
import 'package:lms/repositories/quiz_repository.dart';
import 'package:lms/services/quiz_service.dart';

import 'tabs/info_tab.dart';
import 'tabs/lesson_mentor_tab.dart';
import 'tabs/quiz_tab.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Chi tiết khóa học',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Chỉnh sửa',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurface.withOpacity(0.7),
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: theme.textTheme.titleMedium,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(width: 3, color: cs.primary),
              insets: EdgeInsets.zero,
            ),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(icon: Icon(Icons.info_outline), text: 'Thông tin'),
              Tab(icon: Icon(Icons.menu_book_outlined), text: 'Bài học'),
              Tab(icon: Icon(Icons.quiz_outlined), text: 'Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InfoTab(course: course),
            LessonMentorTab(courseId: course['id']),
            BlocProvider(
              create:
                  (_) =>
                      QuizCubit(QuizRepository(QuizService()))
                        ..getQuizzesByCourseId(course['id']),
              child: QuizTab(courseId: course['id']),
            ),
          ],
        ),
      ),
    );
  }
}
