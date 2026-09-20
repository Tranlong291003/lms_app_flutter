import 'package:lms/apps/utils/json_parse.dart';

class BookmarkModel {
  final int id;
  final int courseId;
  final String userUid;
  final DateTime createdAt;

  /// Thông tin khóa học kèm theo trong response của `GET /api/bookmarks/:user_uid`
  /// (`course_title`, `course_thumbnail`), giúp hiển thị bookmark ngay cả khi
  /// chưa tải được danh sách khóa học.
  final String? courseTitle;
  final String? courseThumbnail;

  BookmarkModel({
    required this.id,
    required this.courseId,
    required this.userUid,
    required this.createdAt,
    this.courseTitle,
    this.courseThumbnail,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    // Backend trả `created_at` dạng ISO; `bookmark_id` là INT nhưng vẫn đọc
    // qua helper để chịu được cả trường hợp chuỗi.
    return BookmarkModel(
      id: asInt(json['bookmark_id'] ?? json['id']),
      courseId: asInt(json['course_id'] ?? json['courseId']),
      userUid: asString(json['user_uid'] ?? json['userUid']),
      createdAt: asDateTimeOr(json['created_at'] ?? json['createdAt'], DateTime.now()),
      courseTitle: asStringOrNull(json['course_title'] ?? json['courseTitle']),
      courseThumbnail: asStringOrNull(
        json['course_thumbnail'] ?? json['courseThumbnail'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmark_id': id,
      'course_id': courseId,
      'user_uid': userUid,
      'created_at': createdAt.toIso8601String(),
      'course_title': courseTitle,
      'course_thumbnail': courseThumbnail,
    };
  }

  BookmarkModel copyWith({
    int? id,
    int? courseId,
    String? userUid,
    DateTime? createdAt,
    String? courseTitle,
    String? courseThumbnail,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      userUid: userUid ?? this.userUid,
      createdAt: createdAt ?? this.createdAt,
      courseTitle: courseTitle ?? this.courseTitle,
      courseThumbnail: courseThumbnail ?? this.courseThumbnail,
    );
  }
}
