import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/cubits/question/question_cubit.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/screens/quiz/components/quiz_detailed_result.dart';
import 'package:lms/screens/quiz/components/quiz_navigation.dart';
import 'package:lms/screens/quiz/components/quiz_question_card.dart';
import 'package:lms/screens/quiz/components/quiz_question_list.dart';
import 'package:lms/screens/quiz/components/quiz_submit_dialog.dart';
import 'package:lms/screens/quiz/components/quiz_timer.dart';
import 'package:lms/services/question_service.dart';

class QuizQuestionsScreen extends StatefulWidget {
  final int quizId;
  final QuizModel? quizInfo;

  const QuizQuestionsScreen({super.key, required this.quizId, this.quizInfo});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  late QuestionCubit _questionCubit;
  final PageController _pageController = PageController();

  // Timer cho thời gian làm bài
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isTimeUp = false;
  bool _isLoading = true;
  String _explanationText = '';
  bool _hasLoadedQuestions = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedQuestions) {
      _initQuiz();
      _hasLoadedQuestions = true;
    }
  }

  @override
  void initState() {
    super.initState();
    final questionService = QuestionService();
    final questionRepository = QuestionRepository(questionService);
    _questionCubit = QuestionCubit(questionRepository);
  }

  Future<void> _initQuiz() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _checkAttempts();
    } catch (e) {
      print('Lỗi khi khởi tạo bài kiểm tra: $e');
      // Nếu có lỗi khi kiểm tra số lần làm, vẫn cho phép làm bài
      _loadQuestions();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAttempts() async {
    await _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      int questionCount = 0;
      final args = ModalRoute.of(context)?.settings.arguments;
      print('DEBUG: arguments vào màn làm bài: $args');
      if (args != null &&
          args is Map<String, dynamic> &&
          args['questionCount'] != null) {
        questionCount = args['questionCount'] as int;
      }
      print('DEBUG: questionCount truyền vào Cubit: $questionCount');
      await _questionCubit.loadQuestionsByQuizId(
        widget.quizId,
        quizInfo: widget.quizInfo,
        maxQuestions: questionCount > 0 ? questionCount : null,
      );
      print(
        'DEBUG: Số câu hỏi thực tế sau khi load: ${_questionCubit.state.questions.length}',
      );

      // Khởi tạo timer nếu có giới hạn thời gian
      if (mounted &&
          widget.quizInfo != null &&
          widget.quizInfo!.timeLimit > 0) {
        _startTimer(widget.quizInfo!.timeLimit);
      }
    } catch (e) {
      print('Lỗi khi tải câu hỏi: $e');
    }
  }

  void _startTimer(int minutes) {
    // Xóa timer cũ nếu có
    _timer?.cancel();

    // Khởi tạo số giây
    setState(() {
      _remainingSeconds = minutes * 60;
      _isTimeUp = false;
    });

    // Khởi tạo timer mới
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isTimeUp = true;
            _timer?.cancel();
            _autoSubmitQuiz();
          }
        });
      } else {
        // Nếu widget đã bị dispose thì hủy timer
        timer.cancel();
      }
    });
  }

  void _autoSubmitQuiz() async {
    if (!_questionCubit.state.isQuizSubmitted && mounted) {
      setState(() {
        _isTimeUp = true;
      });
      // Gọi nộp bài tự động khi hết giờ
      await _submitQuizAuto();
    }
  }

  Future<void> _submitQuizAuto() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userUid =
          context.read<UserBloc>().state is UserLoaded
              ? (context.read<UserBloc>().state as UserLoaded).user.uid
              : null;
      if (userUid == null) {
        throw Exception('Không tìm thấy thông tin người dùng');
      }
      final Map<String, int?> answers = {};
      final questions = _questionCubit.state.questions;
      for (int i = 0; i < questions.length; i++) {
        // Luôn ghi lại tất cả câu hỏi, nếu chưa trả lời thì để null
        answers[questions[i].questionId.toString()] =
            _questionCubit.state.userAnswers[i] >= 0
                ? _questionCubit.state.userAnswers[i]
                : null;
      }
      final result = await _questionCubit.submitQuizResult(
        widget.quizId,
        userUid,
        answers,
        explanation: _explanationText.isEmpty ? null : _explanationText,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (result['success'] == true) {
          _showResult();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Có lỗi xảy ra khi nộp bài'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi nộp bài: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatRemainingTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor() {
    if (_remainingSeconds < 60) {
      return Colors.red;
    } else if (_remainingSeconds < 300) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getTimerBackgroundColor() {
    if (_remainingSeconds < 60) {
      return Colors.red.withOpacity(0.2);
    } else if (_remainingSeconds < 300) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.green.withOpacity(0.2);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _questionCubit.close();
    super.dispose();
  }

  void _selectAnswer(int questionIndex, int answerIndex) {
    _questionCubit.selectAnswer(questionIndex, answerIndex);
  }

  void _navigateToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _resetQuiz() async {
    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
      _explanationText = '';
    });

    // Reset timer nếu có
    _timer?.cancel();

    // Reset state
    _questionCubit.reset();

    // Tải lại câu hỏi
    await _loadQuestions();
  }

  void _showResult() {
    final totalCorrect = _questionCubit.getCorrectAnswersCount();
    final totalQuestions = _questionCubit.state.questions.length;
    final score = _questionCubit.getScore();
    final resultId =
        _questionCubit.state.quizResult?['data']?['result_id'] ??
        _questionCubit.state.quizResult?['result_id'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.blue,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kết quả kiểm tra',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    score.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'điểm',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đúng',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$totalCorrect câu',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          const Icon(Icons.cancel, color: Colors.red, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'Sai',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${totalQuestions - totalCorrect} câu',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Đóng dialog kết quả
                            Navigator.of(context).pop();
                            // Lùi về màn hình trước đó
                            Navigator.of(context).pop();
                            // Lùi thêm 1 màn hình nữa
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Đóng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              resultId != null
                                  ? () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(
                                      context,
                                      '/quiz-result-detail',
                                      arguments: {'resultId': resultId},
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                resultId != null
                                    ? Colors.blue
                                    : Colors.grey[300],
                            foregroundColor:
                                resultId != null ? Colors.white : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Xem chi tiết kết quả',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
    );
  }

  void _showDetailedResult() {
    if (_questionCubit.state.quizResult == null) {
      // Hiển thị kết quả dựa trên dữ liệu local nếu không có kết quả từ API
      final questions = _questionCubit.state.questions;
      final userAnswers = _questionCubit.state.userAnswers;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => QuizDetailedResult(
              result: {
                'questions':
                    questions
                        .map(
                          (q) => {
                            'text': q.question,
                            'options': q.options,
                            'user_answer':
                                userAnswers[questions.indexOf(q)] >= 0
                                    ? q.options[userAnswers[questions.indexOf(
                                      q,
                                    )]]
                                    : 'Chưa trả lời',
                            'correct_answer': q.options[q.correctIndex],
                            'is_correct':
                                userAnswers[questions.indexOf(q)] ==
                                q.correctIndex,
                            'explanation': q.expectedKeywords,
                          },
                        )
                        .toList(),
                'score': _questionCubit.getScore(),
              },
              onClose: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
      );
    } else {
      // Hiển thị kết quả từ API
      final quizResult = _questionCubit.state.quizResult!;
      final questions = quizResult['questions'] as List<dynamic>;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => QuizDetailedResult(
              result: quizResult,
              onClose: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
      );
    }
  }

  void _showQuestionList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return BlocProvider.value(
          value: _questionCubit,
          child: BlocBuilder<QuestionCubit, QuestionState>(
            builder: (context, state) {
              return QuizQuestionList(
                totalQuestions: state.questions.length,
                selectedQuestionIndex: state.selectedQuestionIndex,
                answeredQuestions:
                    state.userAnswers.map((a) => a >= 0).toList(),
                remainingSeconds: _remainingSeconds,
                attemptsUsed: widget.quizInfo?.attemptsUsed ?? 0,
                attemptLimit: widget.quizInfo?.attemptLimit ?? 0,
                answeredCount: state.userAnswers.where((a) => a >= 0).length,
                onQuestionSelected: _navigateToQuestion,
                onSubmit: () {
                  Navigator.of(context).pop();
                  _showSubmitConfirmationDialog();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showSubmitConfirmationDialog() {
    final totalAnswered =
        _questionCubit.state.userAnswers.where((a) => a >= 0).length;
    final totalQuestions = _questionCubit.state.questions.length;

    showDialog(
      context: context,
      builder:
          (context) => QuizSubmitDialog(
            totalAnswered: totalAnswered,
            totalQuestions: totalQuestions,
            explanationText: _explanationText,
            onExplanationChanged: (value) => _explanationText = value,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: () async {
              Navigator.of(context).pop();

              setState(() {
                _isLoading = true;
              });

              try {
                final userUid =
                    context.read<UserBloc>().state is UserLoaded
                        ? (context.read<UserBloc>().state as UserLoaded)
                            .user
                            .uid
                        : null;

                if (userUid == null) {
                  throw Exception('Không tìm thấy thông tin người dùng');
                }

                final Map<String, int?> answers = {};
                final questions = _questionCubit.state.questions;
                for (int i = 0; i < questions.length; i++) {
                  answers[questions[i].questionId.toString()] =
                      _questionCubit.state.userAnswers[i] >= 0
                          ? _questionCubit.state.userAnswers[i]
                          : null;
                }

                final result = await _questionCubit.submitQuizResult(
                  widget.quizId,
                  userUid,
                  answers,
                  explanation:
                      _explanationText.isEmpty ? null : _explanationText,
                );

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });

                  if (result['success'] == true) {
                    _showResult();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Có lỗi xảy ra khi nộp bài',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi nộp bài: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_questionCubit.state.isQuizSubmitted && !_isTimeUp) {
          final shouldSubmit = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Cảnh báo'),
                  content: const Text(
                    'Không thể quay lại khi đang làm kiểm tra. Nếu quay lại, hệ thống sẽ tự động nộp bài.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Đồng ý'),
                    ),
                  ],
                ),
          );
          if (shouldSubmit == true) {
            await _submitQuizAuto();
            return true;
          }
          return false;
        }
        return true;
      },
      child: BlocProvider.value(
        value: _questionCubit,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.quizInfo?.title ?? 'Bài kiểm tra ${widget.quizId}',
            ),
            actions: [
              if (widget.quizInfo != null &&
                  widget.quizInfo!.timeLimit > 0 &&
                  !_isTimeUp)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: QuizTimer(
                      remainingSeconds: _remainingSeconds,
                      onTimeUp: _autoSubmitQuiz,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.list),
                onPressed: _showQuestionList,
                tooltip: 'Danh sách câu hỏi',
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: LoadingIndicator())
                  : BlocBuilder<QuestionCubit, QuestionState>(
                    builder: (context, state) {
                      if (state.status == QuestionStatus.loading) {
                        return const Center(child: LoadingIndicator());
                      }

                      if (state.status == QuestionStatus.error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã xảy ra lỗi: ${state.errorMessage ?? ''}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadQuestions,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state.questions.isEmpty) {
                        return const Center(
                          child: Text(
                            'Không có câu hỏi nào cho bài kiểm tra này',
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Thông tin quiz
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  if (Theme.of(context).brightness ==
                                      Brightness.light)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Thời gian: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${widget.quizInfo?.timeLimit ?? "Không giới hạn"} phút',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.help_outline,
                                            color: Colors.purple.shade400,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Số câu: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${state.questions.length}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: Colors.orange.shade400,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Lần: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${widget.quizInfo?.attemptsUsed ?? 0}/${widget.quizInfo?.attemptLimit ?? 0}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.green.shade400,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Đã trả lời: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${state.userAnswers.where((a) => a >= 0).length}/${state.questions.length}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Card câu hỏi và đáp án
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: state.questions.length,
                                onPageChanged: (index) {
                                  _questionCubit.selectQuestion(index);
                                },
                                itemBuilder: (context, index) {
                                  final question = state.questions[index];
                                  return QuizQuestionCard(
                                    question: question.question,
                                    options: question.options,
                                    selectedOption: _questionCubit
                                        .getUserAnswer(index),
                                    isSubmitted: state.isQuizSubmitted,
                                    isTimeUp: _isTimeUp,
                                    onOptionSelected:
                                        (optionIndex) =>
                                            _selectAnswer(index, optionIndex),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Thanh điều hướng
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                            child: QuizNavigation(
                              currentQuestionIndex:
                                  state.selectedQuestionIndex ?? 0,
                              totalQuestions: state.questions.length,
                              isTimeUp: _isTimeUp,
                              isSubmitted: state.isQuizSubmitted,
                              onPrevious: () {
                                _questionCubit.previousQuestion();
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              onNext: () {
                                _questionCubit.nextQuestion();
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              onSubmit: _showSubmitConfirmationDialog,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
