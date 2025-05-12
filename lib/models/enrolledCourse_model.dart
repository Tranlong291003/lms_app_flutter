// lib/models/enrolled_course.dart
class EnrolledCourse {
  final int courseId;
  final String title;
  final String? thumbnailUrl;
  final int totalLessons;
  final int completedLessons;
  final int progressPercent;

  /// Tổng thời lượng toàn khóa – đã định dạng sẵn, ví dụ: "44 phút" hoặc "1 Giờ 30 phút"
  final String totalDuration;

  EnrolledCourse({
    required this.courseId,
    required this.title,
    this.thumbnailUrl,
    required this.totalLessons,
    required this.completedLessons,
    required this.progressPercent,
    required this.totalDuration,
  });

  /// Kiểm tra xem khóa học đã hoàn thành chưa
  bool get isCompleted =>
      progressPercent >= 100 || completedLessons >= totalLessons;

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    try {
      // In ra thông tin json để debug
      print('[EnrolledCourse] Đang parse JSON: $json');

      return EnrolledCourse(
        courseId: json['course_id'] as int? ?? 0,
        title: json['title'] as String? ?? 'Khóa học không có tiêu đề',
        thumbnailUrl: json['thumbnail_url'] as String?,
        totalLessons: json['total_lessons'] as int? ?? 0,
        completedLessons: json['completed_lessons'] as int? ?? 0,
        progressPercent: json['progress_percent'] as int? ?? 0,
        totalDuration: json['total_duration'] as String? ?? '0 phút',
      );
    } catch (e) {
      print('[EnrolledCourse] Lỗi khi parse JSON: $e');
      print('[EnrolledCourse] JSON gốc: $json');

      // Trả về một đối tượng mặc định khi có lỗi
      return EnrolledCourse(
        courseId: 0,
        title: 'Lỗi dữ liệu',
        thumbnailUrl: null,
        totalLessons: 0,
        completedLessons: 0,
        progressPercent: 0,
        totalDuration: '0 phút',
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'title': title,
    'thumbnail_url': thumbnailUrl,
    'total_lessons': totalLessons,
    'completed_lessons': completedLessons,
    'progress_percent': progressPercent,
    'total_duration': totalDuration,
  };
}
