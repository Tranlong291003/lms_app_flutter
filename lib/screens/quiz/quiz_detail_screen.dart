import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_router.dart';

class QuizDetailScreen extends StatelessWidget {
  const QuizDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
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
    final questions = quiz['questions'] as List<dynamic>? ?? [];

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
                  Text(
                    quiz['description'] as String? ?? 'Không có mô tả',
                    style: GoogleFonts.poppins(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
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
                      '${quiz['questionCount'] ?? questions.length} câu hỏi',
                    ),
                    _buildInfoItem(
                      Icons.timer_outlined,
                      '${quiz['duration'] ?? 30} phút',
                    ),
                    _buildInfoItem(
                      Icons.star_outline,
                      'Độ khó: ${quiz['difficulty'] ?? 'Trung bình'}',
                    ),
                  ]),
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
                      'Không thể quay lại câu hỏi đã trả lời',
                    ),
                  ]),
                  const SizedBox(height: 32),
                  if (questions.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.quizQuestions,
                            arguments: quiz,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: quizColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Bắt đầu làm bài',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Text(
                        'Bài kiểm tra này chưa có câu hỏi',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ),
                  ],
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
          Text(text, style: GoogleFonts.poppins(fontSize: 14)),
        ],
      ),
    );
  }
}
