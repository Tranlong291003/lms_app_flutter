import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/models/lesson_model.dart';
import 'package:lms/screens/course_detail/lesson_detail_screen.dart';

class LessonMentorTab extends StatelessWidget {
  final int courseId;

  const LessonMentorTab({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';
    final cubit = context.read<LessonsCubit>();

    // Load lessons when widget is built
    cubit.loadLessons(courseId: courseId, userUid: userUid);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addLesson(context, userUid),
        tooltip: 'Thêm bài học',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (context, state) {
          if (state is LessonsLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is LessonsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Có lỗi xảy ra: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => cubit.loadLessons(
                          courseId: courseId,
                          userUid: userUid,
                        ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is LessonsLoaded) {
            final lessons = state.lessons;
            if (lessons.isEmpty) {
              return const Center(
                child: Text('Chưa có bài học nào trong khóa học này.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final user = FirebaseAuth.instance.currentUser;
                final userUid = user?.uid ?? '';
                await context.read<LessonsCubit>().loadLessons(
                  courseId: courseId,
                  userUid: userUid,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  final lesson = lessons[index];
                  return LessonCard(
                    lesson: lesson,
                    onTap: () => _navigateToLessonDetail(context, lesson),
                    onEdit: () {
                      final cubit = context.read<LessonsCubit>();
                      Lesson latestLesson = lesson;
                      final state = cubit.state;
                      if (state is LessonsLoaded) {
                        final found = state.lessons.firstWhere(
                          (l) => l.lessonId == lesson.lessonId,
                          orElse: () => lesson,
                        );
                        latestLesson = found;
                      }
                      _editLesson(context, latestLesson);
                    },
                    onDelete: () => _deleteLesson(context, lesson),
                    onRefresh: () => _refreshLesson(context, lesson),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _addLesson(BuildContext context, String userUid) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => LessonFormDialog(courseId: courseId, userUid: userUid),
    );
    if (result == true && context.mounted) {
      await context.read<LessonsCubit>().loadLessons(
        courseId: courseId,
        userUid: userUid,
      );
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Tạo bài học mới thành công',
        );
      }
    }
  }

  void _navigateToLessonDetail(BuildContext context, Lesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => LessonDetailScreen(
              lessonId: lesson.lessonId,
              courseId: courseId,
            ),
      ),
    ).then((_) {
      if (!context.mounted) return;
      context.read<LessonsCubit>().loadLessons(
        courseId: courseId,
        userUid: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
    });
  }

  /// Xử lý chỉnh sửa bài học bằng dialog
  Future<void> _editLesson(BuildContext context, Lesson lesson) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => LessonFormDialog(
            courseId: courseId,
            userUid: FirebaseAuth.instance.currentUser?.uid ?? '',
            lesson: lesson,
            isEditing: true,
          ),
    );
    if (result == true && context.mounted) {
      await context.read<LessonsCubit>().loadLessons(
        courseId: courseId,
        userUid: FirebaseAuth.instance.currentUser?.uid ?? '',
      );
      if (context.mounted) {
        CustomSnackBar.showSuccess(
          context: context,
          message: 'Cập nhật bài học thành công',
        );
      }
    }
  }

  /// Xử lý xoá bài học
  Future<void> _deleteLesson(BuildContext context, Lesson lesson) async {
    try {
      // Hiển thị dialog xác nhận
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Xác nhận xoá'),
              content: Text(
                'Bạn có chắc chắn muốn xoá bài học "${lesson.title}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Huỷ'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Xoá'),
                ),
              ],
            ),
      );

      if (confirmed == true && context.mounted) {
        // Gọi cubit để xoá bài học
        await context.read<LessonsCubit>().deleteLesson(
          lessonId: lesson.lessonId,
          courseId: courseId,
          userUid: FirebaseAuth.instance.currentUser?.uid ?? '',
        );

        if (context.mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Xoá bài học thành công',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Lỗi xoá bài học: ${e.toString()}',
        );
      }
    }
  }

  void _refreshLesson(BuildContext context, Lesson lesson) {
    // TODO: Gọi API cập nhật trạng thái hoặc reload chi tiết bài học
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng cập nhật bài học đang phát triển!'),
      ),
    );
  }
}

/// Widget hiển thị thông tin một bài học với các nút thao tác dạng slidable
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(lesson.lessonId),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Xoá',
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Sửa',
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            ),
          ],
        ),
        child: Material(
          elevation: 1,
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book, color: theme.primaryColor, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lesson.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (lesson.content?.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text(
                            lesson.content ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson.videoDuration ?? '0:00',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.video_library,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson.videoUrl.isNotEmpty
                                  ? '1 video'
                                  : 'Không có video',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.blue),
                    tooltip: 'Cập nhật',
                    onPressed: onRefresh,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonFormDialog extends StatefulWidget {
  final int courseId;
  final String userUid;
  final Lesson? lesson;
  final bool isEditing; // Thêm flag để xác định đang sửa hay tạo mới

  const LessonFormDialog({
    super.key,
    required this.courseId,
    required this.userUid,
    this.lesson,
    this.isEditing = false, // Mặc định là tạo mới
  });

  @override
  State<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends State<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _contentController = TextEditingController();
  final _orderController = TextEditingController();
  File? _pdfFile;
  File? _slideFile;
  bool _isLoading = false;
  String? _currentPdfName;
  String? _currentSlideName;

  @override
  void initState() {
    super.initState();

    // DEBUG: Kiểm tra dữ liệu khi khởi tạo state
    print('===== DEBUG LESSON FORM DIALOG - INIT STATE =====');
    print('Is editing mode: ${widget.lesson != null}');

    if (widget.lesson != null) {
      final lesson = widget.lesson!;

      print('Lesson ID: ${lesson.lessonId}');
      print('Title: [33m${lesson.title} (Empty: ${lesson.title.isEmpty})');
      print(
        'Content: [33m${lesson.content ?? ''} (Empty: ${(lesson.content ?? '').isEmpty})',
      );
      print('VideoUrl: ${lesson.videoUrl} (Empty: ${lesson.videoUrl.isEmpty})');
      print('Order: ${lesson.order}');
      print(
        'PDF URL: ${lesson.pdfUrl} (Null: ${lesson.pdfUrl == null}, Empty: ${lesson.pdfUrl?.isEmpty})',
      );
      print(
        'Slide URL: ${lesson.slideUrl} (Null: ${lesson.slideUrl == null}, Empty: ${lesson.slideUrl?.isEmpty})',
      );

      // Gán dữ liệu cũ vào controller
      _titleController.text = lesson.title;
      print('Title controller after set: ${_titleController.text}');

      _videoUrlController.text = lesson.videoUrl;
      print('Video URL controller after set: ${_videoUrlController.text}');

      _contentController.text = lesson.content ?? '';
      print('Content controller after set: ${_contentController.text}');

      _orderController.text = lesson.order.toString();
      print('Order controller after set: ${_orderController.text}');

      if (lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty) {
        _currentPdfName = lesson.pdfUrl!.split('/').last;
        print('PDF name set: $_currentPdfName');
      } else {
        print('PDF URL is null or empty, not setting name');
      }

      if (lesson.slideUrl != null && lesson.slideUrl!.isNotEmpty) {
        _currentSlideName = lesson.slideUrl!.split('/').last;
        print('Slide name set: $_currentSlideName');
      } else {
        print('Slide URL is null or empty, not setting name');
      }
    } else {
      print('No lesson data provided (adding new lesson)');
    }

    print('===== END DEBUG =====');
  }

  @override
  void didUpdateWidget(covariant LessonFormDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    // DEBUG: Kiểm tra khi widget update
    print('===== DEBUG LESSON FORM DIALOG - DID UPDATE WIDGET =====');
    print('Old lesson null: ${oldWidget.lesson == null}');
    print('New lesson null: ${widget.lesson == null}');
    print('Lessons different: ${widget.lesson != oldWidget.lesson}');

    if (widget.lesson != null && widget.lesson != oldWidget.lesson) {
      final lesson = widget.lesson!;

      print('Updating with new lesson data:');
      print('Lesson ID: ${lesson.lessonId}');
      print('Title: ${lesson.title}');
      print('Content: ${lesson.content}');

      _titleController.text = lesson.title;
      _videoUrlController.text = lesson.videoUrl;
      _contentController.text = lesson.content ?? '';
      _orderController.text = lesson.order.toString();

      if (lesson.pdfUrl != null && lesson.pdfUrl!.isNotEmpty) {
        _currentPdfName = lesson.pdfUrl!.split('/').last;
      }

      if (lesson.slideUrl != null && lesson.slideUrl!.isNotEmpty) {
        _currentSlideName = lesson.slideUrl!.split('/').last;
      }

      print('Controllers updated, calling setState');
      setState(() {});
    } else {
      print('No update needed');
    }

    print('===== END DEBUG =====');
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cubit = context.read<LessonsCubit>();
      if (widget.isEditing && widget.lesson != null) {
        await cubit.updateLesson(
          lessonId: widget.lesson!.lessonId,
          courseId: widget.courseId,
          title: _titleController.text.trim(),
          videoUrl: _videoUrlController.text.trim(),
          content: _contentController.text.trim(),
          order: int.tryParse(_orderController.text.trim()) ?? 1,
          uid: widget.userUid,
          pdf: _pdfFile,
          slide: _slideFile,
        );
      } else {
        await cubit.createLesson(
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
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (context.mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    theme.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Chỉnh sửa bài học' : 'Thêm bài học mới',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isEditing && widget.lesson != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${widget.lesson!.lessonId}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin hiện tại (chỉ hiển thị khi đang chỉnh sửa)
                      if (isEditing && widget.lesson != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Thông tin hiện tại',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Tiêu đề',
                                widget.lesson!.title,
                                theme,
                              ),
                              if (widget.lesson!.content?.isNotEmpty == true)
                                _buildInfoRow(
                                  'Nội dung',
                                  widget.lesson!.content!,
                                  theme,
                                  isMultiline: true,
                                ),
                              if (widget.lesson!.videoUrl.isNotEmpty)
                                _buildInfoRow(
                                  'Video URL',
                                  widget.lesson!.videoUrl,
                                  theme,
                                ),
                              _buildInfoRow(
                                'Thứ tự',
                                widget.lesson!.order.toString(),
                                theme,
                              ),
                              if (widget.lesson!.pdfUrl?.isNotEmpty == true)
                                _buildInfoRow(
                                  'PDF',
                                  widget.lesson!.pdfUrl!,
                                  theme,
                                ),
                              if (widget.lesson!.slideUrl?.isNotEmpty == true)
                                _buildInfoRow(
                                  'Slide',
                                  widget.lesson!.slideUrl!,
                                  theme,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Form fields
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề bài học',
                          hintText: 'Nhập tiêu đề bài học',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator:
                            (v) =>
                                v?.isEmpty ?? true
                                    ? 'Vui lòng nhập tiêu đề'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _videoUrlController,
                        decoration: InputDecoration(
                          labelText: 'Video URL',
                          hintText:
                              (widget.lesson?.videoUrl.isEmpty ?? true)
                                  ? 'Chưa có video, nhập URL mới nếu muốn'
                                  : 'Nhập URL video bài học',
                          prefixIcon: const Icon(Icons.video_library),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          labelText: 'Nội dung bài học',
                          hintText:
                              (widget.lesson?.content?.isEmpty ?? true)
                                  ? 'Chưa có nội dung, nhập nội dung mới nếu muốn'
                                  : 'Nhập nội dung bài học',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              Icons.description_outlined,
                              color: theme.colorScheme.primary.withOpacity(0.8),
                              size: 22,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 50,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerLowest,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          alignLabelWithHint: true,
                        ),
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          height: 1.5,
                        ),
                        maxLines: 8,
                        minLines: 5,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orderController,
                        decoration: InputDecoration(
                          labelText: 'Thứ tự bài học',
                          hintText: 'Nhập thứ tự bài học',
                          prefixIcon: const Icon(Icons.sort),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Vui lòng nhập thứ tự';
                          if (int.tryParse(v!) == null)
                            return 'Thứ tự phải là số';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickFile(true),
                              icon: const Icon(Icons.picture_as_pdf),
                              label: Text(
                                _pdfFile != null
                                    ? _pdfFile!.path.split('/').last
                                    : isEditing && _currentPdfName != null
                                    ? 'Giữ nguyên PDF'
                                    : 'Chọn PDF',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickFile(false),
                              icon: const Icon(Icons.slideshow),
                              label: Text(
                                _slideFile != null
                                    ? _slideFile!.path.split('/').last
                                    : isEditing && _currentSlideName != null
                                    ? 'Giữ nguyên Slide'
                                    : 'Chọn Slide',
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer với nút hành động
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? 'Cập nhật' : 'Tạo bài học'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ThemeData theme, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: isMultiline ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
