class BookmarkModel {
  final int id;
  final int courseId;
  final String userUid;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.courseId,
    required this.userUid,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    // Xử lý trường hợp API trả về {data: {bookmark_id: 57}}
    if (json.containsKey('bookmark_id')) {
      // Trường hợp API trả về trực tiếp với bookmark_id
      return BookmarkModel(
        id: json['bookmark_id'] as int,
        courseId: json['course_id'] as int? ?? 0,
        userUid: json['user_uid'] as String? ?? '',
        createdAt:
            json['created_at'] != null
                ? DateTime.parse(json['created_at'] as String)
                : DateTime.now(),
      );
    }

    // Xử lý trường hợp API trả về với id
    return BookmarkModel(
      id: json['id'] as int? ?? json['bookmark_id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? json['course_id'] as int? ?? 0,
      userUid: json['userUid'] as String? ?? json['user_uid'] as String? ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : (json['created_at'] != null
                  ? DateTime.parse(json['created_at'] as String)
                  : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'userUid': userUid,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
