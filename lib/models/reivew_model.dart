import 'package:lms/apps/utils/json_parse.dart';

class Review {
  final int reviewId;
  final int courseId;
  final String userUid;
  final String userName;
  final String userAvatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Review({
    required this.reviewId,
    required this.courseId,
    required this.userUid,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  /// Lưu ý: `review_id`/`course_id` là `SERIAL` nên PostgreSQL trả về dạng
  /// **chuỗi** trong JSON — phải đọc qua helper thay vì ép `as int`.
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: asInt(json['review_id']),
      courseId: asInt(json['course_id']),
      userUid: asString(json['user_uid']),
      userName: asString(json['user_name']),
      userAvatarUrl: asString(json['user_avatar_url']),
      rating: asInt(json['rating']),
      comment: asString(json['comment']),
      createdAt: asDateTimeOr(json['created_at'], DateTime.now()),
      updatedAt: asDateTime(json['updated_at']),
    );
  }

  // Convert Review object into JSON
  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'course_id': courseId,
      'user_uid': userUid,
      'user_name': userName,
      'user_avatar_url': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
