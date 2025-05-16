import 'package:flutter/material.dart';

class QuizFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const QuizFormDialog({super.key, this.initialData});

  @override
  State<QuizFormDialog> createState() => _QuizFormDialogState();
}

class _QuizFormDialogState extends State<QuizFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _typeController.text = widget.initialData!['type'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Thêm Quiz' : 'Sửa Quiz'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên Quiz'),
              validator: (v) => v == null || v.isEmpty ? 'Nhập tên quiz' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Loại Quiz'),
              validator:
                  (v) => v == null || v.isEmpty ? 'Nhập loại quiz' : null,
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
                'title': _titleController.text.trim(),
                'type': _typeController.text.trim(),
                'questions': widget.initialData?['questions'] ?? [],
              });
            }
          },
          child: Text(widget.initialData == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
