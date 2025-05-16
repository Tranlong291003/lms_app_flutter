import 'package:flutter/material.dart';

import 'question_form_dialog.dart';

class QuestionListDialog extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const QuestionListDialog({super.key, required this.quiz});

  @override
  State<QuestionListDialog> createState() => _QuestionListDialogState();
}

class _QuestionListDialogState extends State<QuestionListDialog> {
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    questions = List<Map<String, dynamic>>.from(widget.quiz['questions'] ?? []);
  }

  void addQuestion() async {
    final method = await showDialog<String>(
      context: context,
      builder:
          (ctx) => SimpleDialog(
            title: const Text('Chọn cách thêm câu hỏi'),
            children: [
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'ai'),
                child: const Text('Tạo bằng AI'),
              ),
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, 'manual'),
                child: const Text('Tự nhập'),
              ),
            ],
          ),
    );
    if (method == 'manual') {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (ctx) => const QuestionFormDialog(),
      );
      if (result != null) {
        setState(() {
          questions.add(result);
          widget.quiz['questions'] = questions;
        });
      }
    } else if (method == 'ai') {
      // TODO: Gọi API AI để sinh câu hỏi
      // Demo: Thêm câu hỏi mẫu
      setState(() {
        questions.add({'question': 'Câu hỏi AI mẫu', 'answer': 'Đáp án'});
        widget.quiz['questions'] = questions;
      });
    }
  }

  void editQuestion(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => QuestionFormDialog(initialData: questions[index]),
    );
    if (result != null) {
      setState(() {
        questions[index] = result;
        widget.quiz['questions'] = questions;
      });
    }
  }

  void deleteQuestion(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Bạn có chắc chắn muốn xoá câu hỏi này?'),
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
        questions.removeAt(index);
        widget.quiz['questions'] = questions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Danh sách câu hỏi'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Câu hỏi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm câu hỏi'),
                  onPressed: addQuestion,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...questions.asMap().entries.map((entry) {
              final i = entry.key;
              final q = entry.value;
              return Card(
                child: ListTile(
                  title: Text(q['question'] ?? ''),
                  subtitle: Text(q['answer'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editQuestion(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () => deleteQuestion(i),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
