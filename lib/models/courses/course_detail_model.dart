import 'package:lms/apps/utils/json_parse.dart';

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
      courseId: asInt(json['course_id']),
      title: asString(json['title']),
      description: asString(json['description']),
      level: asString(json['level']),
      language: asString(json['language']),
      tags: asString(json['tags']),
      price: asInt(json['price']),
      discountPrice: asInt(json['discount_price']),
      status: asString(json['status'], 'pending'),
      approvedAt: asDateTime(json['approved_at']),
      thumbnailUrl: asStringOrNull(json['thumbnail_url']),
      createdAt: asDateTimeOr(
        json['created_at'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
      updatedAt: asDateTimeOr(
        json['updated_at'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
      categoryId: asInt(json['category_id']),
      categoryName: asString(json['category_name']),
      instructorUid: asString(json['instructor_uid']),
      instructorName: asString(json['instructor_name']),
      instructorAvatarUrl: asStringOrNull(json['instructor_avatar_url']),
      instructorBio: asStringOrNull(json['instructor_bio']),
      avgRating: asDoubleOrNull(json['avg_rating']),
      reviewCount: asInt(json['review_count']),
      enrollmentCount: asInt(json['enrollment_count']),
      totalVideoDuration: asString(json['total_video_duration'], '00:00:00'),
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
