import 'package:flutter/material.dart';

class QuestionFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const QuestionFormDialog({super.key, this.initialData});

  @override
  State<QuestionFormDialog> createState() => _QuestionFormDialogState();
}

class _QuestionFormDialogState extends State<QuestionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _questionController.text = widget.initialData!['question'] ?? '';
      _answerController.text = widget.initialData!['answer'] ?? '';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Thêm câu hỏi' : 'Sửa câu hỏi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionController,
              decoration: const InputDecoration(labelText: 'Nội dung câu hỏi'),
              validator: (v) => v == null || v.isEmpty ? 'Nhập nội dung' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: 'Đáp án'),
              validator: (v) => v == null || v.isEmpty ? 'Nhập đáp án' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context, {
                'question': _questionController.text.trim(),
                'answer': _answerController.text.trim(),
              });
            }
          },
          child: Text(widget.initialData == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
