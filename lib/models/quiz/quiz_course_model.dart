import 'package:lms/models/quiz/quiz_model.dart';

class QuizCourseModel {
  final int courseId;
  final String courseTitle;
  final List<QuizModel> quizzes;

  const QuizCourseModel({
    required this.courseId,
    required this.courseTitle,
    required this.quizzes,
  });

  factory QuizCourseModel.fromJson(Map<String, dynamic> json) {
    List<QuizModel> quizzesList = [];

    if (json['quizzes'] != null) {
      if (json['quizzes'] is List) {
        quizzesList =
            (json['quizzes'] as List)
                .map(
                  (quiz) => quiz is QuizModel ? quiz : QuizModel.fromJson(quiz),
                )
                .toList();
      }
    }

    return QuizCourseModel(
      courseId: json['courseId'],
      courseTitle: json['courseTitle'],
      quizzes: quizzesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseTitle': courseTitle,
      'quizzes': quizzes.map((quiz) => quiz.toJson()).toList(),
    };
  }
}
