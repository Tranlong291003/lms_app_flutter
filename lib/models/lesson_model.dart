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
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    lessonId:
        json['lesson_id'] is int
            ? json['lesson_id']
            : int.tryParse(json['lesson_id']?.toString() ?? '0') ?? 0,
    courseId:
        json['course_id'] is int
            ? json['course_id']
            : int.tryParse(json['course_id']?.toString() ?? '0') ?? 0,
    title: json['title']?.toString() ?? '',
    videoUrl: json['video_url']?.toString() ?? '',
    pdfUrl: json['pdf_url']?.toString(),
    slideUrl: json['slide_url']?.toString(),
    content: json['content']?.toString(),
    order:
        json['order'] is int
            ? json['order']
            : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
    createdAt:
        json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
    updatedAt:
        json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null,
    creatorUid: json['creator_uid']?.toString() ?? '',
    videoId: json['video_id']?.toString(),
    videoDuration: json['video_duration']?.toString(),
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
  };

  @override
  String toString() {
    return 'Lesson(lessonId: $lessonId, title: $title, videoUrl: $videoUrl, content: $content, order: $order,  pdfUrl: $pdfUrl, slideUrl: $slideUrl)';
  }
}
