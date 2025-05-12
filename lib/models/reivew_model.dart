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

  // Convert JSON data into Review object
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'],
      courseId: json['course_id'],
      userUid: json['user_uid'],
      userName: json['user_name'],
      userAvatarUrl: json['user_avatar_url'] ?? '',
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
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
