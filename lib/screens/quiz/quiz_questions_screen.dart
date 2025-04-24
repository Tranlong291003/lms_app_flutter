import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizQuestionsScreen extends StatefulWidget {
  const QuizQuestionsScreen({super.key});

  @override
  State<QuizQuestionsScreen> createState() => _QuizQuestionsScreenState();
}

class _QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  bool isAnswered = false;
  List<int?> userAnswers = [];

  @override
  Widget build(BuildContext context) {
    final quiz =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (quiz == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy dữ liệu bài kiểm tra')),
      );
    }

    final questions = quiz['questions'] as List<dynamic>;
    final currentQuestion =
        questions[currentQuestionIndex] as Map<String, dynamic>;
    final options = currentQuestion['options'] as List<dynamic>;
    final quizColor = quiz['color'] as Color? ?? Colors.blue;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          quiz['title'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / questions.length,
            valueColor: AlwaysStoppedAnimation<Color>(quizColor),
          ),

          // Question counter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu hỏi ${currentQuestionIndex + 1}/${questions.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: quizColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 18, color: quizColor),
                      const SizedBox(width: 4),
                      Text(
                        '${quiz['duration']} phút',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: quizColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Question
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: quizColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentQuestion['question'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap:
                            isAnswered
                                ? null
                                : () {
                                  setState(() {
                                    selectedAnswerIndex = index;
                                    isAnswered = true;
                                    userAnswers.add(index);
                                  });
                                },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _getOptionBorderColor(
                                index,
                                currentQuestion['correctAnswer'] as int,
                              ),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: _getOptionBackgroundColor(
                              index,
                              currentQuestion['correctAnswer'] as int,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _getOptionBorderColor(
                                      index,
                                      currentQuestion['correctAnswer'] as int,
                                    ),
                                    width: 2,
                                  ),
                                  color: _getOptionBackgroundColor(
                                    index,
                                    currentQuestion['correctAnswer'] as int,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(
                                      65 + index,
                                    ), // A, B, C, D
                                    style: GoogleFonts.poppins(
                                      color: _getOptionTextColor(
                                        index,
                                        currentQuestion['correctAnswer'] as int,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  options[index] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: _getOptionTextColor(
                                      index,
                                      currentQuestion['correctAnswer'] as int,
                                    ),
                                  ),
                                ),
                              ),
                              if (isAnswered && index == selectedAnswerIndex)
                                Icon(
                                  index == currentQuestion['correctAnswer']
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color:
                                      index == currentQuestion['correctAnswer']
                                          ? Colors.green
                                          : Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentQuestionIndex--;
                          selectedAnswerIndex =
                              userAnswers[currentQuestionIndex];
                          isAnswered = selectedAnswerIndex != null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: BorderSide(color: quizColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Câu trước',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: quizColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        !isAnswered
                            ? null
                            : () {
                              if (currentQuestionIndex < questions.length - 1) {
                                setState(() {
                                  currentQuestionIndex++;
                                  selectedAnswerIndex =
                                      currentQuestionIndex < userAnswers.length
                                          ? userAnswers[currentQuestionIndex]
                                          : null;
                                  isAnswered = selectedAnswerIndex != null;
                                });
                              } else {
                                // TODO: Show results
                                Navigator.pop(context);
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: quizColor,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      currentQuestionIndex < questions.length - 1
                          ? 'Câu tiếp theo'
                          : 'Kết thúc',
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
    );
  }

  Color _getOptionBorderColor(int optionIndex, int correctAnswer) {
    if (!isAnswered) {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]!
          : Colors.grey[700]!;
    }
    if (optionIndex == selectedAnswerIndex) {
      return optionIndex == correctAnswer ? Colors.green : Colors.red;
    }
    if (optionIndex == correctAnswer) return Colors.green;
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
  }

  Color _getOptionBackgroundColor(int optionIndex, int correctAnswer) {
    if (!isAnswered) return Theme.of(context).scaffoldBackgroundColor;
    if (optionIndex == selectedAnswerIndex) {
      return optionIndex == correctAnswer
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1);
    }
    if (optionIndex == correctAnswer) return Colors.green.withOpacity(0.1);
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color _getOptionTextColor(int optionIndex, int correctAnswer) {
    if (!isAnswered) return Theme.of(context).textTheme.bodyLarge!.color!;
    if (optionIndex == selectedAnswerIndex) {
      return optionIndex == correctAnswer ? Colors.green : Colors.red;
    }
    if (optionIndex == correctAnswer) return Colors.green;
    return Theme.of(context).textTheme.bodyLarge!.color!;
  }
}
