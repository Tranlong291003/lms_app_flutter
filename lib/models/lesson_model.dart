class Lesson {
  final int lessonId;
  final int courseId;
  final String title;
  final String videoUrl;
  final String? pdfUrl;
  final String? slideUrl;
  final String content;
  final int order;
  final bool isPreview;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String creatorUid;
  final String? videoId;
  final String? videoDuration;

  Lesson({
    required this.lessonId,
    required this.courseId,
    required this.title,
    required this.videoUrl,
    this.pdfUrl,
    this.slideUrl,
    required this.content,
    required this.order,
    required this.isPreview,
    required this.createdAt,
    this.updatedAt,
    required this.creatorUid,
    this.videoId,
    this.videoDuration,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    // Xử lý lesson_id và course_id
    final lessonId = json['lesson_id'];
    final courseId = json['course_id'];

    if (lessonId == null || courseId == null) {
      throw Exception('lesson_id và course_id không được phép null');
    }

    return Lesson(
      lessonId: lessonId is int ? lessonId : int.parse(lessonId.toString()),
      courseId: courseId is int ? courseId : int.parse(courseId.toString()),
      title: json['title'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      pdfUrl: json['pdf_url'] as String?,
      slideUrl: json['slide_url'] as String?,
      content: json['content'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      // hỗn hợp int (0/1) hoặc bool
      isPreview:
          json['is_preview'] is int
              ? (json['is_preview'] as int) == 1
              : (json['is_preview'] as bool? ?? false),
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      creatorUid: json['creator_uid'] as String? ?? '',
      videoId: json['video_id'] as String?,
      videoDuration: json['video_duration'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'lesson_id': lessonId,
    'course_id': courseId,
    'title': title,
    'video_url': videoUrl,
    'pdf_url': pdfUrl,
    'slide_url': slideUrl,
    'content': content,
    'order': order,
    // gửi về server nếu cần, dùng 0/1
    'is_preview': isPreview ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'creator_uid': creatorUid,
    'video_id': videoId,
    'video_duration': videoDuration,
  };
}
