import 'package:lms/apps/utils/json_parse.dart';

class Lesson {
  final int lessonId;
  final int courseId;
  final String title;
  final String videoUrl;
  final String? pdfUrl;
  final String? slideUrl;
  final String? content;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String creatorUid;
  final String? videoId;
  final String? videoDuration;
  final bool isCompleted;

  Lesson({
    required this.lessonId,
    required this.courseId,
    required this.title,
    required this.videoUrl,
    this.pdfUrl,
    this.slideUrl,
    this.content,
    required this.order,
    required this.createdAt,
    this.updatedAt,
    required this.creatorUid,
    this.videoId,
    this.videoDuration,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    lessonId: asInt(json['lesson_id']),
    courseId: asInt(json['course_id']),
    title: asString(json['title']),
    videoUrl: asString(json['video_url']),
    pdfUrl: asStringOrNull(json['pdf_url']),
    slideUrl: asStringOrNull(json['slide_url']),
    content: asStringOrNull(json['content']),
    order: asInt(json['order']),
    createdAt: asDateTimeOr(json['created_at'], DateTime.now()),
    updatedAt: asDateTime(json['updated_at']),
    creatorUid: asString(json['creator_uid']),
    videoId: asStringOrNull(json['video_id']),
    videoDuration: asStringOrNull(json['video_duration']),
    // Backend trả `is_completed` dạng số (1/0), có thể là chuỗi với BIGINT.
    isCompleted: asBool(json['is_completed']),
  );

  Map<String, dynamic> toJson() => {
    'lesson_id': lessonId,
    'course_id': courseId,
    'title': title,
    'video_url': videoUrl,
    'pdf_url': pdfUrl,
    'slide_url': slideUrl,
    'content': content,
    'order': order,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'creator_uid': creatorUid,
    'video_id': videoId,
    'video_duration': videoDuration,
    'is_completed': isCompleted ? 1 : 0,
  };

  @override
  String toString() {
    return 'Lesson(lessonId: $lessonId, title: $title, videoUrl: $videoUrl, content: $content, order: $order, pdfUrl: $pdfUrl, slideUrl: $slideUrl, isCompleted: $isCompleted)';
  }
}
