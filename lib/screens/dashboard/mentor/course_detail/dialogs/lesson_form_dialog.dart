import 'package:flutter/material.dart';

class LessonFormDialog extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const LessonFormDialog({super.key, this.initialData});

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _descController.text = widget.initialData!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Thêm bài học' : 'Sửa bài học'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tên bài học'),
              validator:
                  (v) => v == null || v.isEmpty ? 'Nhập tên bài học' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              validator: (v) => v == null || v.isEmpty ? 'Nhập mô tả' : null,
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
                'description': _descController.text.trim(),
              });
            }
          },
          child: Text(widget.initialData == null ? 'Thêm' : 'Lưu'),
        ),
      ],
    );
  }
}
