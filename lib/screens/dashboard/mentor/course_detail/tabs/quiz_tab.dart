import 'package:flutter/material.dart';

import '../dialogs/question_list_dialog.dart';
import '../dialogs/quiz_form_dialog.dart';

class QuizTab extends StatefulWidget {
  final Map<String, dynamic> course;

  const QuizTab({super.key, required this.course});

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  late List<Map<String, dynamic>> quizzes;

  @override
  void initState() {
    super.initState();
    quizzes = List<Map<String, dynamic>>.from(widget.course['quizList'] ?? []);
  }

  void addQuiz() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const QuizFormDialog(),
    );
    if (result != null) {
      setState(() {
        quizzes.add(result);
        widget.course['quizList'] = quizzes;
      });
    }
  }

  void editQuiz(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => QuizFormDialog(initialData: quizzes[index]),
    );
    if (result != null) {
      setState(() {
        quizzes[index] = result;
        widget.course['quizList'] = quizzes;
      });
    }
  }

  void deleteQuiz(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Bạn có chắc chắn muốn xoá quiz này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xoá', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true) {
      setState(() {
        quizzes.removeAt(index);
        widget.course['quizList'] = quizzes;
      });
    }
  }

  void showQuestions(int quizIndex) async {
    await showDialog(
      context: context,
      builder: (ctx) => QuestionListDialog(quiz: quizzes[quizIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'Danh sách Quiz',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Thêm Quiz'),
                onPressed: addQuiz,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.quiz, color: theme.colorScheme.primary),
                  title: Text(quiz['title'] ?? 'Quiz'),
                  subtitle: Text(quiz['type'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.question_answer),
                        tooltip: 'Xem câu hỏi',
                        onPressed: () => showQuestions(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Sửa quiz',
                        onPressed: () => editQuiz(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: theme.colorScheme.error,
                        tooltip: 'Xóa quiz',
                        onPressed: () => deleteQuiz(index),
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
