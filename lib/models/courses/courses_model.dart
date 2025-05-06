// lib/models/courses/course_model.dart
class Course {
  final int courseId;
  final String title;
  final String instructorUid;
  final int categoryId;
  final int price;
  final String level;
  final int discountPrice;
  final String? thumbnailUrl;
  final String status;
  final DateTime updatedAt;
  final String instructorName;
  final String categoryName;
  final double rating; // Trung bình đánh giá
  final int enrollCount; // Số người đăng ký

  Course({
    required this.courseId,
    required this.title,
    required this.instructorUid,
    required this.categoryId,
    required this.price,
    required this.level,
    required this.discountPrice,
    this.thumbnailUrl,
    required this.status,
    required this.updatedAt,
    required this.instructorName,
    required this.categoryName,
    required this.rating,
    required this.enrollCount,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      instructorUid: json['instructor_uid'] as String,
      categoryId: json['category_id'] as int,
      price: json['price'] as int,
      level: json['level'] as String,
      discountPrice: json['discount_price'] as int,
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      instructorName: json['instructor_name'] as String,
      categoryName: json['category_name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      enrollCount: json['enroll_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'title': title,
    'instructor_uid': instructorUid,
    'category_id': categoryId,
    'price': price,
    'level': level,
    'discount_price': discountPrice,
    'thumbnail_url': thumbnailUrl,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'instructor_name': instructorName,
    'category_name': categoryName,
    'rating': rating,
    'enroll_count': enrollCount,
  };
}
