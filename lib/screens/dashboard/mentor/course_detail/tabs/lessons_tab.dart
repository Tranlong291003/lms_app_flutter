import 'package:flutter/material.dart';

import '../dialogs/lesson_form_dialog.dart';

class LessonsTab extends StatefulWidget {
  final Map<String, dynamic> course;

  const LessonsTab({super.key, required this.course});

  @override
  State<LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<LessonsTab> {
  late List<Map<String, dynamic>> lessons;

  @override
  void initState() {
    super.initState();
    lessons = List<Map<String, dynamic>>.from(
      widget.course['lessonsList'] ?? [],
    );
  }

  void addLesson() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const LessonFormDialog(),
    );
    if (result != null) {
      setState(() {
        lessons.add(result);
        widget.course['lessonsList'] = lessons;
      });
    }
  }

  void editLesson(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => LessonFormDialog(initialData: lessons[index]),
    );
    if (result != null) {
      setState(() {
        lessons[index] = result;
        widget.course['lessonsList'] = lessons;
      });
    }
  }

  void deleteLesson(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Xác nhận xoá'),
            content: const Text('Bạn có chắc chắn muốn xoá bài học này?'),
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
        lessons.removeAt(index);
        widget.course['lessonsList'] = lessons;
      });
    }
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
                'Danh sách bài học',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Thêm bài học'),
                onPressed: addLesson,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.menu_book,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(lesson['title'] ?? 'Bài học'),
                  subtitle: Text(lesson['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Sửa bài học',
                        onPressed: () => editLesson(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: theme.colorScheme.error,
                        tooltip: 'Xóa bài học',
                        onPressed: () => deleteLesson(index),
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
