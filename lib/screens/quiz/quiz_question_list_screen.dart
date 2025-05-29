import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/question/question_cubit.dart';
import 'package:lms/models/quiz/question_model.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/services/question_service.dart';

class QuizQuestionListScreen extends StatelessWidget {
  final int quizId;
  const QuizQuestionListScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              QuestionCubit(QuestionRepository(QuestionService()))
                ..loadQuestionsByQuizId(quizId),
      child: _QuizQuestionListView(quizId: quizId),
    );
  }
}

class _QuizQuestionListView extends StatelessWidget {
  final int quizId;
  const _QuizQuestionListView({required this.quizId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách câu hỏi')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateQuestionDialog(context, quizId),
        tooltip: 'Thêm câu hỏi mới',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<QuestionCubit, QuestionState>(
        builder: (context, state) {
          if (state.status == QuestionStatus.loading) {
            return const Center(child: LoadingIndicator());
          }
          if (state.status == QuestionStatus.error) {
            return const Center(
              child: Text('Chưa có câu hỏi nào cho quiz này.'),
            );
          }
          final questions = state.questions;
          if (questions.isEmpty) {
            return const Center(
              child: Text('Chưa có câu hỏi nào cho quiz này.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await context.read<QuestionCubit>().loadQuestionsByQuizId(quizId);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final q = questions[index];
                return Slidable(
                  key: ValueKey(q.questionId),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.22,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => _EditQuestionDialog(question: q),
                          );
                          if (result == true && context.mounted) {
                            context.read<QuestionCubit>().loadQuestionsByQuizId(
                              quizId,
                            );
                            CustomSnackBar.showSuccess(
                              context: context,
                              message: 'Cập nhật thành công!',
                            );
                          }
                        },
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Sửa',
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.22,
                    children: [
                      SlidableAction(
                        onPressed: (_) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xoá'),
                                  content: const Text(
                                    'Bạn có chắc chắn muốn xoá câu hỏi này?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Huỷ'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Xoá',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );

                          if (confirm == true) {
                            final currentContext = context;
                            final uid =
                                FirebaseAuth.instance.currentUser?.uid ?? '';
                            final ok = await currentContext
                                .read<QuestionCubit>()
                                .deleteQuestion(q.questionId, {
                                  "uid": uid,
                                }, quizId);

                            if (currentContext.mounted) {
                              if (ok) {
                                CustomSnackBar.showSuccess(
                                  context: currentContext,
                                  message: 'Xoá thành công!',
                                );
                                currentContext
                                    .read<QuestionCubit>()
                                    .loadQuestionsByQuizId(quizId);
                              } else {
                                CustomSnackBar.showError(
                                  context: currentContext,
                                  message: 'Xoá thất bại!',
                                );
                              }
                            }
                          }
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xoá',
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ],
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Câu ${index + 1}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(q.question),
                          const SizedBox(height: 8),
                          ...q.options.asMap().entries.map((entry) {
                            final i = entry.key;
                            final opt = entry.value;
                            final isCorrect = i == q.correctIndex;
                            return Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isCorrect ? Colors.green : Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(opt)),
                              ],
                            );
                          }),
                          const SizedBox(height: 8),
                          Text(
                            'Tạo lúc: ${q.getFormattedCreatedDate()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void showCreateQuestionDialog(BuildContext context, int quizId) async {
    final option = await showModalBottomSheet<String>(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: const Text('Tạo thủ công'),
                  onTap: () => Navigator.pop(ctx, 'manual'),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Tạo bằng AI'),
                  onTap: () => Navigator.pop(ctx, 'ai'),
                ),
              ],
            ),
          ),
    );

    if (!context.mounted) return;

    bool? result;

    if (option == 'manual') {
      // Mở dialog tạo câu hỏi bằng tay
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _CreateQuestionManualDialog(quizId: quizId),
      );
    } else if (option == 'ai') {
      // Mở dialog tạo câu hỏi bằng AI
      result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _CreateQuestionAIDialog(quizId: quizId),
      );
    }

    if (context.mounted && result != null) {
      if (result == true) {
        context.read<QuestionCubit>().loadQuestionsByQuizId(quizId);
        CustomSnackBar.showSuccess(
          context: context,
          message:
              option == 'manual'
                  ? 'Tạo câu hỏi thành công!'
                  : 'Tạo câu hỏi bằng AI thành công!',
        );
      } else {
        CustomSnackBar.showError(
          context: context,
          message:
              option == 'manual'
                  ? 'Tạo câu hỏi thất bại!'
                  : 'Tạo câu hỏi bằng AI thất bại!',
        );
      }
    }
  }
}

class _EditQuestionDialog extends StatefulWidget {
  final QuestionModel question;
  const _EditQuestionDialog({required this.question});

  @override
  State<_EditQuestionDialog> createState() => _EditQuestionDialogState();
}

class _EditQuestionDialogState extends State<_EditQuestionDialog> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController questionController;
  late List<TextEditingController> optionControllers;
  int correctIndex = 0;

  @override
  void initState() {
    super.initState();
    questionController = TextEditingController(text: widget.question.question);
    optionControllers = List.generate(
      widget.question.options.length,
      (i) => TextEditingController(text: widget.question.options[i]),
    );
    correctIndex = widget.question.correctIndex;
  }

  @override
  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa câu hỏi'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung câu hỏi',
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Nhập nội dung' : null,
              ),
              const SizedBox(height: 12),
              ...List.generate(
                optionControllers.length,
                (i) => Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: correctIndex,
                      onChanged: (v) => setState(() => correctIndex = v ?? 0),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: optionControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Đáp án ${String.fromCharCode(65 + i)}',
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Nhập đáp án' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
            final data = {
              'question': questionController.text.trim(),
              'type': 'trac_nghiem',
              'options': optionControllers.map((c) => c.text.trim()).toList(),
              'correct_index': correctIndex,
              'uid': uid,
            };
            final ok = await context.read<QuestionCubit>().updateQuestion(
              widget.question.questionId,
              data,
              widget.question.quizId,
            );
            if (ok && context.mounted) {
              Navigator.pop(context, true);
            } else if (context.mounted) {
              CustomSnackBar.showError(
                context: context,
                message: 'Cập nhật thất bại!',
              );
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _CreateQuestionManualDialog extends StatefulWidget {
  final int quizId;
  const _CreateQuestionManualDialog({required this.quizId});

  @override
  State<_CreateQuestionManualDialog> createState() =>
      _CreateQuestionManualDialogState();
}

class _CreateQuestionManualDialogState
    extends State<_CreateQuestionManualDialog> {
  final formKey = GlobalKey<FormState>();
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int correctIndex = 0;
  bool isLoading = false;

  @override
  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo câu hỏi thủ công'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung câu hỏi',
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Nhập nội dung' : null,
              ),
              const SizedBox(height: 12),
              ...List.generate(
                optionControllers.length,
                (i) => Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: correctIndex,
                      onChanged: (v) => setState(() => correctIndex = v ?? 0),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: optionControllers[i],
                        decoration: InputDecoration(
                          labelText: 'Đáp án ${String.fromCharCode(65 + i)}',
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Nhập đáp án' : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      isLoading = true;
                    });

                    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    final data = {
                      'quiz_id': widget.quizId,
                      'question': questionController.text.trim(),
                      'type': 'trac_nghiem',
                      'options':
                          optionControllers.map((c) => c.text.trim()).toList(),
                      'correct_index': correctIndex,
                      'uid': uid,
                    };
                    final ok = await context
                        .read<QuestionCubit>()
                        .createQuestionManual(data, widget.quizId);

                    if (context.mounted) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context, ok);
                    }
                  },
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingIndicator(),
                  )
                  : const Text('Tạo'),
        ),
      ],
    );
  }
}

class _CreateQuestionAIDialog extends StatefulWidget {
  final int quizId;
  const _CreateQuestionAIDialog({required this.quizId});

  @override
  State<_CreateQuestionAIDialog> createState() =>
      _CreateQuestionAIDialogState();
}

class _CreateQuestionAIDialogState extends State<_CreateQuestionAIDialog> {
  final formKey = GlobalKey<FormState>();
  final topicController = TextEditingController();
  int number = 5;
  String difficulty = 'medium';
  bool isLoading = false;

  static const Map<String, String> difficultyMap = {
    'easy': 'Dễ',
    'medium': 'Trung Bình',
    'hard': 'Khó',
  };

  @override
  void dispose() {
    topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo câu hỏi bằng AI'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TextFormField(
                controller: topicController,
                decoration: const InputDecoration(labelText: 'Chủ đề câu hỏi'),
                validator: (v) => v == null || v.isEmpty ? 'Nhập chủ đề' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: number.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số lượng câu hỏi',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Nhập số lượng câu hỏi';
                  final n = int.tryParse(v);
                  if (n == null) return 'Vui lòng nhập số hợp lệ';
                  if (n <= 0) return 'Số lượng phải lớn hơn 0';
                  if (n > 50) return 'Tối đa 50 câu hỏi';
                  return null;
                },
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n > 0 && n <= 50) {
                    setState(() => number = n);
                  }
                },
                enabled: !isLoading,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: InputDecoration(
                  labelText: 'Độ khó',
                  prefixIcon: Icon(
                    Icons.speed_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'easy',
                    child: Row(children: [Text(difficultyMap['easy']!)]),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Row(children: [Text(difficultyMap['medium']!)]),
                  ),
                  DropdownMenuItem(
                    value: 'hard',
                    child: Row(children: [Text(difficultyMap['hard']!)]),
                  ),
                ],
                onChanged:
                    isLoading
                        ? null
                        : (v) => setState(() => difficulty = v ?? 'medium'),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                dropdownColor: Theme.of(context).colorScheme.surface,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              const SizedBox(height: 12),
              if (isLoading) const Center(child: LoadingIndicator()),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed:
              isLoading
                  ? null
                  : () async {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      isLoading = true;
                    });

                    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                    final data = {
                      'uid': uid,
                      'quiz_id': widget.quizId,
                      'topic': topicController.text.trim(),
                      'number': number,
                      'type': 'trac_nghiem',
                      'difficulty': difficulty,
                      'language': 'vi',
                    };
                    final ok = await context
                        .read<QuestionCubit>()
                        .createQuestionAI(data, widget.quizId);

                    if (context.mounted) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context, ok);
                    }
                  },
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingIndicator(),
                  )
                  : const Text('Tạo'),
        ),
      ],
    );
  }
}
