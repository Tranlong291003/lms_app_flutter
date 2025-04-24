import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/app_router.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  final List<Map<String, dynamic>> quizzes = const [
    {
      'title': 'Bài kiểm tra Flutter cơ bản',
      'description': '10 câu hỏi về kiến thức cơ bản Flutter.',
      'icon': Icons.flutter_dash,
      'color': Color(0xFF2196F3),
      'questionCount': 10,
      'duration': 30,
      'difficulty': 'Trung bình',
      'questions': [
        {
          'question': 'Widget nào dùng để tạo danh sách có thể cuộn?',
          'options': ['ListView', 'Container', 'Row', 'Column'],
          'correctAnswer': 0,
        },
        // Thêm các câu hỏi khác ở đây
      ],
    },
    {
      'title': 'Bài kiểm tra Dart nâng cao',
      'description': 'Kiểm tra tư duy lập trình với Dart.',
      'icon': Icons.code,
      'color': Color(0xFF9C27B0),
      'questionCount': 15,
      'duration': 45,
      'difficulty': 'Nâng cao',
      'questions': [
        {
          'question': 'Future và Stream trong Dart là gì?',
          'options': [
            'Xử lý bất đồng bộ một giá trị',
            'Xử lý đồng bộ',
            'Xử lý collection',
            'Không có đáp án đúng',
          ],
          'correctAnswer': 0,
        },
        // Thêm các câu hỏi khác ở đây
      ],
    },
    {
      'title': 'Bài kiểm tra UI/UX',
      'description': 'Câu hỏi về thiết kế giao diện và trải nghiệm người dùng.',
      'icon': Icons.design_services,
      'color': Color(0xFFFF9800),
      'questionCount': 12,
      'duration': 35,
      'difficulty': 'Trung bình',
      'questions': [
        {
          'question': 'Nguyên tắc quan trọng nhất trong thiết kế UI/UX là gì?',
          'options': [
            'Tính dễ sử dụng',
            'Tính thẩm mỹ',
            'Tính sáng tạo',
            'Tính đồng nhất',
          ],
          'correctAnswer': 0,
        },
        // Thêm các câu hỏi khác ở đây
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Danh sách bài kiểm tra',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          final quizColor = quiz['color'] as Color? ?? Colors.blue;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.quizDetail,
                    arguments: quiz,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              quizColor.withOpacity(0.2),
                              quizColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          quiz['icon'] as IconData? ?? Icons.quiz,
                          color: quizColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quiz['title'] as String? ?? 'Bài kiểm tra',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              quiz['description'] as String? ??
                                  'Không có mô tả',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: quizColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: quizColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
