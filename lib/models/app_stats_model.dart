import 'package:lms/apps/utils/json_parse.dart';

class AppStatsModel {
  final String role;
  final int totalCourses;
  final int? totalStudents; // mentor
  final int? totalLessons; // mentor
  final double? avgRating; // mentor
  final int? totalUsers; // admin
  final int? totalQuizzes; // admin
  final int? totalReviews; // admin

  const AppStatsModel({
    required this.role,
    required this.totalCourses,
    this.totalStudents,
    this.totalLessons,
    this.avgRating,
    this.totalUsers,
    this.totalQuizzes,
    this.totalReviews,
  });

  /// Mọi giá trị đều là kết quả `COUNT()`/`AVG()` của PostgreSQL nên có thể
  /// được trả về dạng **chuỗi** trong JSON — đọc qua helper để không vỡ kiểu.
  factory AppStatsModel.fromJson(Map<String, dynamic> json) {
    return AppStatsModel(
      role: asString(json['role']),
      totalCourses: asInt(json['total_courses']),
      totalStudents: asIntOrNull(json['total_students']),
      totalLessons: asIntOrNull(json['total_lessons']),
      avgRating: asDoubleOrNull(json['avg_rating']),
      totalUsers: asIntOrNull(json['total_users']),
      totalQuizzes: asIntOrNull(json['total_quizzes']),
      totalReviews: asIntOrNull(json['total_reviews']),
    );
  }
}
