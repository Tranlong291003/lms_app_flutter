import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/widgets/custom_snackbar.dart';

class LessonEditScreen extends StatefulWidget {
  final Lesson lesson;
  final int courseId;
  final String userUid;
  const LessonEditScreen({
    super.key,
    required this.lesson,
    required this.courseId,
    required this.userUid,
  });

  @override
  State<LessonEditScreen> createState() => _LessonEditScreenState();
}

class _LessonEditScreenState extends State<LessonEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _videoUrlController;
  late final TextEditingController _contentController;
  late final TextEditingController _orderController;
  File? _pdfFile;
  File? _slideFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // DEBUG: Kiểm tra dữ liệu lesson truyền vào
    print(
      'DEBUG lesson: \\n  id: \\${widget.lesson.lessonId} \\n  title: \\${widget.lesson.title} \\n  videoUrl: \\${widget.lesson.videoUrl} \\n  content: \\${widget.lesson.content} \\n  order: \\${widget.lesson.order}',
    );
    _titleController = TextEditingController(text: widget.lesson.title);
    _videoUrlController = TextEditingController(text: widget.lesson.videoUrl);
    _contentController = TextEditingController(
      text: widget.lesson.content ?? '',
    );
    _orderController = TextEditingController(
      text: widget.lesson.order.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _videoUrlController.dispose();
    _contentController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isPdf) async {
    final result = await FilePicker.platform.pickFiles(
      type: isPdf ? FileType.custom : FileType.custom,
      allowedExtensions: isPdf ? ['pdf'] : ['ppt', 'pptx', 'pdf'],
      withData: false,
      dialogTitle: isPdf ? 'Chọn file PDF' : 'Chọn file Slide',
    );
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      setState(() {
        if (isPdf) {
          _pdfFile = file;
        } else {
          _slideFile = file;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    context.read<LessonsCubit>().updateLesson(
      lessonId: widget.lesson.lessonId,
      courseId: widget.courseId,
      title: _titleController.text.trim(),
      videoUrl: _videoUrlController.text.trim(),
      content: _contentController.text.trim(),
      order: int.tryParse(_orderController.text.trim()) ?? 1,
      uid: widget.userUid,
      pdf: _pdfFile,
      slide: _slideFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật bài học')),
      body: BlocListener<LessonsCubit, LessonsState>(
        listener: (context, state) {
          if (state is LessonsLoaded) {
            Navigator.pop(context, true);
            CustomSnackBar.showSuccess(
              context: context,
              message: 'Cập nhật bài học thành công!',
            );
          }
          if (state is LessonsError) {
            setState(() => _isLoading = false);
            CustomSnackBar.showError(
              context: context,
              message: 'Lỗi: ${state.message}',
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Nhập tiêu đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(labelText: 'Video URL'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Nội dung'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(labelText: 'Thứ tự'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập thứ tự';
                  if (int.tryParse(v) == null) return 'Thứ tự phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickFile(true),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(
                        _pdfFile != null
                            ? _pdfFile!.path.split('/').last
                            : 'Chọn PDF (bỏ trống nếu chưa có)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickFile(false),
                      icon: const Icon(Icons.slideshow),
                      label: Text(
                        _slideFile != null
                            ? _slideFile!.path.split('/').last
                            : 'Chọn Slide (bỏ trống nếu chưa có)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Cập nhật'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
