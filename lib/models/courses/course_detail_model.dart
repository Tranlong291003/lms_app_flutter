class CourseDetail {
  final int courseId;
  final String title;
  final String description;
  final String level;
  final String language;
  final String tags;
  final int price;
  final int discountPrice;
  final String status;
  final DateTime? approvedAt;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int categoryId;
  final String categoryName;
  final String instructorUid;
  final String instructorName;
  final String? instructorAvatarUrl;
  final String? instructorBio;
  final double? avgRating;
  final int reviewCount;
  final int enrollmentCount;
  final String totalVideoDuration;

  CourseDetail({
    required this.courseId,
    required this.title,
    required this.description,
    required this.level,
    required this.language,
    required this.tags,
    required this.price,
    required this.discountPrice,
    required this.status,
    this.approvedAt,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    required this.categoryName,
    required this.instructorUid,
    required this.instructorName,
    this.instructorAvatarUrl,
    this.instructorBio,
    this.avgRating,
    required this.reviewCount,
    required this.enrollmentCount,
    required this.totalVideoDuration,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      language: json['language'] as String,
      tags: json['tags'] as String,
      price: json['price'] as int,
      discountPrice: json['discount_price'] as int,
      status: json['status'] as String,
      approvedAt:
          json['approved_at'] != null
              ? DateTime.tryParse(json['approved_at'])
              : null,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      instructorUid: json['instructor_uid'] as String,
      instructorName: json['instructor_name'] as String,
      instructorAvatarUrl: json['instructor_avatar_url'] as String?,
      instructorBio: json['instructor_bio'] as String?,
      avgRating:
          json['avg_rating'] != null
              ? (json['avg_rating'] as num?)?.toDouble()
              : null,
      reviewCount: json['review_count'] as int,
      enrollmentCount: json['enrollment_count'] as int,
      totalVideoDuration: json['total_video_duration'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'title': title,
    'description': description,
    'level': level,
    'language': language,
    'tags': tags,
    'price': price,
    'discount_price': discountPrice,
    'status': status,
    'approved_at': approvedAt?.toIso8601String(),
    'thumbnail_url': thumbnailUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'category_id': categoryId,
    'category_name': categoryName,
    'instructor_uid': instructorUid,
    'instructor_name': instructorName,
    'instructor_avatar_url': instructorAvatarUrl,
    'instructor_bio': instructorBio,
    'avg_rating': avgRating,
    'review_count': reviewCount,
    'enrollment_count': enrollmentCount,
    'total_video_duration': totalVideoDuration,
  };
}
