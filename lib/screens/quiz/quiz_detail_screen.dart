import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../apps/config/app_router.dart';
import '../../models/quiz/quiz_model.dart';
import '../../repositories/question_repository.dart';
import '../../services/question_service.dart';

class QuizDetailScreen extends StatefulWidget {
  const QuizDetailScreen({super.key});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  bool _isLoading = false;
  int _questionsCount = 0;
  int _loadedQuestionsCount = 0; // Tổng số câu hỏi có sẵn
  bool _hasLoadedQuestionsCount = false;

  int getQuestionCountByTime(int timeLimit) {
    switch (timeLimit) {
      case 1:
        return 3; // Test case: 1 phút = 3 câu
      case 15:
        return 10;
      case 30:
        return 20;
      case 45:
        return 30;
      case 60:
        return 40;
      case 90:
        return 50;
      default:
        return 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedQuestionsCount) {
      print('DEBUG: QuizDetailScreen didChangeDependencies');
      _fetchQuestionsCount();
      _hasLoadedQuestionsCount = true;
    }
  }

  @override
  void initState() {
    super.initState();
    print('DEBUG: QuizDetailScreen initState');
  }

  Future<void> _fetchQuestionsCount() async {
    print('DEBUG: _fetchQuestionsCount called');
    final args = ModalRoute.of(context)?.settings.arguments;
    print('DEBUG: args = $args');
    if (args != null && args is Map<String, dynamic>) {
      final quizId = args['quizId'] as int?;
      print('DEBUG: quizId = $quizId');
      if (quizId != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          final questionService = QuestionService();
          final questionRepository = QuestionRepository(questionService);

          print('DEBUG: Sắp gọi API lấy danh sách câu hỏi cho quizId: $quizId');
          final allQuestions = await questionRepository.getQuestionsByQuizId(
            quizId,
          );
          print(
            'DEBUG: Đã gọi xong API lấy danh sách câu hỏi, số lượng: ${allQuestions.length}',
          );
          _loadedQuestionsCount = allQuestions.length;

          // Tính số lượng câu hỏi theo mốc thời gian quy định
          final quizInfo = args['quizInfo'] as QuizModel?;
          int timeLimit = 0;
          if (quizInfo != null) {
            timeLimit = quizInfo.timeLimit;
            final requiredQuestions = getQuestionCountByTime(timeLimit);
            print(
              'DEBUG: timeLimit = $timeLimit, requiredQuestions = $requiredQuestions',
            );

            // Kiểm tra số câu hỏi có đủ không
            if (_loadedQuestionsCount >= requiredQuestions) {
              _questionsCount =
                  requiredQuestions; // Số câu hỏi sẽ làm theo thời gian
              print(
                'DEBUG: Số câu hỏi đủ yêu cầu, sẽ làm $_questionsCount câu',
              );
            } else {
              _questionsCount = 0; // Không đủ câu hỏi, không cho phép làm
              print(
                'DEBUG: Số câu hỏi không đủ yêu cầu (cần $requiredQuestions, có $_loadedQuestionsCount)',
              );
            }
          } else {
            _questionsCount = 0;
          }

          print(
            'DEBUG: Tổng số câu hỏi thực tế từ CSDL: $_loadedQuestionsCount',
          );
          print('DEBUG: Thời gian kiểm tra (timeLimit): $timeLimit');
          print(
            'DEBUG: Số câu hỏi yêu cầu theo thời gian: ${getQuestionCountByTime(timeLimit)}',
          );
          print('DEBUG: QuizInfo: $quizInfo');
          print('DEBUG: Số câu hỏi sẽ làm: $_questionsCount');

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        } catch (e) {
          print('Lỗi khi lấy số lượng câu hỏi: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    }
  }

  void _startQuiz(BuildContext context, Map<String, dynamic> quiz) {
    final quizInfo = quiz['quizInfo'] as QuizModel?;
    if (quizInfo != null) {
      // Kiểm tra nếu số lượng làm bài đã đạt giới hạn
      final int attemptsUsed = quizInfo.attemptsUsed ?? 0;

      if (attemptsUsed >= quizInfo.attemptLimit) {
        _showMaxAttemptsReachedDialog(context, quizInfo.attemptLimit);
      } else {
        print(
          'DEBUG: pushNamed QuizDetailScreen với quizId: ${quiz['quizId']}, quizInfo: $quizInfo',
        );
        Navigator.pushNamed(
          context,
          AppRouter.quizQuestions,
          arguments: {
            'quizId': quiz['quizId'],
            'quizInfo': quizInfo,
            'questionCount': _questionsCount,
          },
        ).then((_) {
          // Làm mới màn hình khi quay lại từ màn hình làm bài
          _fetchQuestionsCount();
        });
      }
    } else {
      Navigator.pushNamed(
        context,
        AppRouter.quizQuestions,
        arguments: {'quizId': quiz['quizId']},
      ).then((_) {
        _fetchQuestionsCount();
      });
    }
  }

  void _showMaxAttemptsReachedDialog(BuildContext context, int limit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(Icons.block, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Đã đạt giới hạn'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn đã làm bài kiểm tra này $limit lần, đạt giới hạn cho phép.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mỗi bài kiểm tra chỉ được làm tối đa $limit lần.',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: QuizDetailScreen build');
    final args = ModalRoute.of(context)?.settings.arguments;
    print('DEBUG: build args = $args');
    if (args == null || args is! Map<String, dynamic>) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chi tiết bài kiểm tra',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text('Không tìm thấy thông tin bài kiểm tra'),
        ),
      );
    }

    final quiz = args;
    final quizColor = quiz['color'] as Color? ?? Colors.blue;
    final quizInfo = quiz['quizInfo'] as QuizModel?;
    final attemptsUsed = quizInfo?.attemptsUsed ?? 0;
    final attemptLimit = quizInfo?.attemptLimit ?? 3;
    final timeLimit = quizInfo?.timeLimit ?? 30;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết bài kiểm tra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    quizColor.withOpacity(0.2),
                    quizColor.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: quizColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      quiz['icon'] as IconData? ?? Icons.quiz,
                      color: quizColor,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    quiz['title'] as String? ?? 'Bài kiểm tra',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Thông tin bài kiểm tra', [
                    _buildInfoItem(
                      Icons.help_outline,
                      _isLoading
                          ? 'Đang tải số lượng câu hỏi...'
                          : _questionsCount > 0
                          ? '$_questionsCount câu hỏi (theo thời gian $timeLimit phút)'
                          : 'Không đủ câu hỏi theo yêu cầu thời gian',
                    ),
                    _buildInfoItem(Icons.timer_outlined, '$timeLimit phút'),

                    _buildInfoItem(
                      Icons.refresh_outlined,
                      'Số lần làm: $attemptsUsed/$attemptLimit',
                    ),
                  ]),
                  if (!_isLoading && _questionsCount == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bài kiểm tra này không đủ số lượng câu hỏi theo yêu cầu thời gian. Vui lòng liên hệ quản trị viên để bổ sung.',
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Hiển thị thông tin về quy tắc số lượng câu hỏi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Quy tắc làm bài',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Với thời gian $timeLimit phút, bài kiểm tra này yêu cầu ${getQuestionCountByTime(timeLimit)} câu hỏi. Hiện tại có $_loadedQuestionsCount câu hỏi trong ngân hàng đề.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection('Hướng dẫn làm bài', [
                    _buildInfoItem(
                      Icons.check_circle_outline,
                      'Đọc kỹ câu hỏi trước khi trả lời',
                    ),
                    _buildInfoItem(
                      Icons.check_circle_outline,
                      'Mỗi câu hỏi chỉ có một đáp án đúng',
                    ),
                    _buildInfoItem(
                      Icons.check_circle_outline,
                      'Bài kiểm tra có giới hạn thời gian',
                    ),
                    _buildInfoItem(
                      Icons.check_circle_outline,
                      'Bài kiểm tra tự động nộp khi hết thời gian',
                    ),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          (_questionsCount == 0 || attemptsUsed >= attemptLimit)
                              ? null
                              : () => _startQuiz(context, quiz),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: quizColor,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _questionsCount == 0
                            ? 'Bài kiểm tra chưa có câu hỏi'
                            : (attemptsUsed >= attemptLimit
                                ? 'Đã đạt giới hạn số lần làm'
                                : 'Bắt đầu làm bài'),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 14))),
        ],
      ),
    );
  }
}
