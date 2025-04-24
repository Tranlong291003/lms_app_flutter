import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizDetailScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;
  const QuizDetailScreen({super.key, required this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int score = 0;
  final TextEditingController _essayController = TextEditingController();
  int? selectedOptionIndex;
  bool submitted = false;

  final Map<String, dynamic> question = {
    'question': 'Flutter là gì?',
    'options': [
      'Ngôn ngữ lập trình',
      'Framework phát triển ứng dụng đa nền tảng',
      'IDE để lập trình',
      'Công cụ thiết kế UI',
    ],
    'answerIndex': 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz['title'], style: GoogleFonts.roboto()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Câu hỏi trắc nghiệm:',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                question['question'],
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...List.generate(question['options'].length, (index) {
                final isSelected = selectedOptionIndex == index;
                final isCorrect = question['answerIndex'] == index;
                Color? color;
                if (submitted) {
                  if (isSelected) {
                    color = isCorrect ? Colors.green : Colors.red;
                  } else if (isCorrect) {
                    color = Colors.green;
                  } else {
                    color = Colors.grey[300];
                  }
                } else {
                  color = isSelected ? Colors.blue[100] : Colors.grey[200];
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap:
                          submitted
                              ? null
                              : () {
                                setState(() {
                                  selectedOptionIndex = index;
                                });
                              },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          question['options'][index],
                          style: GoogleFonts.roboto(),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text(
                'Câu hỏi tự luận:',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Trình bày sự khác biệt giữa StatelessWidget và StatefulWidget trong Flutter.',
                style: GoogleFonts.roboto(fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _essayController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Nhập câu trả lời của bạn...',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed:
                    submitted
                        ? null
                        : () {
                          setState(() {
                            submitted = true;
                            if (selectedOptionIndex ==
                                question['answerIndex']) {
                              score++;
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bài làm đã được nộp.'),
                            ),
                          );
                        },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Nộp bài'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _essayController.dispose();
    super.dispose();
  }
}
