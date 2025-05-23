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

  factory AppStatsModel.fromJson(Map<String, dynamic> json) {
    return AppStatsModel(
      role: json['role'] as String,
      totalCourses: json['total_courses'] as int,
      totalStudents: json['total_students'] as int?,
      totalLessons: json['total_lessons'] as int?,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      totalUsers: json['total_users'] as int?,
      totalQuizzes: json['total_quizzes'] as int?,
      totalReviews: json['total_reviews'] as int?,
    );
  }
}
