// lib/models/courses/course_model.dart
class CourseListResponse {
  final List<Course> pending;
  final List<Course> approved;
  final List<Course> rejected;
  final int total;

  CourseListResponse({
    required this.pending,
    required this.approved,
    required this.rejected,
    required this.total,
  });

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    print('[CourseListResponse] Parsing JSON: $json');

    // Kiểm tra và lấy data một cách an toàn
    final data = json['data'];
    if (data == null) {
      print('[CourseListResponse] Data is null, returning empty lists');
      return CourseListResponse(
        pending: [],
        approved: [],
        rejected: [],
        total: json['total'] as int? ?? 0,
      );
    }

    if (data is! Map<String, dynamic>) {
      print(
        '[CourseListResponse] Data is not Map<String, dynamic>: ${data.runtimeType}',
      );
      return CourseListResponse(
        pending: [],
        approved: [],
        rejected: [],
        total: json['total'] as int? ?? 0,
      );
    }

    // Parse các danh sách với xử lý lỗi
    List<Course> parsePendingList() {
      try {
        final pendingData = data['pending'];
        if (pendingData == null) return [];
        if (pendingData is! List) {
          print(
            '[CourseListResponse] pending is not a List: ${pendingData.runtimeType}',
          );
          return [];
        }
        return pendingData.map<Course>((e) => Course.fromJson(e)).toList();
      } catch (e) {
        print('[CourseListResponse] Error parsing pending list: $e');
        return [];
      }
    }

    List<Course> parseApprovedList() {
      try {
        final approvedData = data['approved'];
        if (approvedData == null) return [];
        if (approvedData is! List) {
          print(
            '[CourseListResponse] approved is not a List: ${approvedData.runtimeType}',
          );
          return [];
        }
        return approvedData.map<Course>((e) => Course.fromJson(e)).toList();
      } catch (e) {
        print('[CourseListResponse] Error parsing approved list: $e');
        return [];
      }
    }

    List<Course> parseRejectedList() {
      try {
        final rejectedData = data['rejected'];
        if (rejectedData == null) return [];
        if (rejectedData is! List) {
          print(
            '[CourseListResponse] rejected is not a List: ${rejectedData.runtimeType}',
          );
          return [];
        }
        return rejectedData.map<Course>((e) => Course.fromJson(e)).toList();
      } catch (e) {
        print('[CourseListResponse] Error parsing rejected list: $e');
        return [];
      }
    }

    final pending = parsePendingList();
    final approved = parseApprovedList();
    final rejected = parseRejectedList();

    print(
      '[CourseListResponse] Parsed successfully: pending=${pending.length}, approved=${approved.length}, rejected=${rejected.length}',
    );

    return CourseListResponse(
      pending: pending,
      approved: approved,
      rejected: rejected,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'data': {
      'pending': pending.map((e) => e.toJson()).toList(),
      'approved': approved.map((e) => e.toJson()).toList(),
      'rejected': rejected.map((e) => e.toJson()).toList(),
    },
    'total': total,
  };
}

class Course {
  final int courseId;
  final String title;
  final String description;
  final String instructorUid;
  final int categoryId;
  final int price;
  final String level;
  final int discountPrice;
  final String? thumbnailUrl;
  final String status;
  final DateTime updatedAt;
  final String instructorName;
  final String? instructorAvatar;
  final String categoryName;
  final double rating; // Trung bình đánh giá
  final int enrollCount; // Số người đăng ký
  final int lessonCount;
  final String totalDuration;
  bool isBookmarked; // Trạng thái bookmark
  final String? rejectionReason; // Lý do từ chối khóa học

  Course({
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructorUid,
    required this.categoryId,
    required this.price,
    required this.level,
    required this.discountPrice,
    this.thumbnailUrl,
    required this.status,
    required this.updatedAt,
    required this.instructorName,
    this.instructorAvatar,
    required this.categoryName,
    required this.rating,
    required this.enrollCount,
    required this.lessonCount,
    required this.totalDuration,
    this.isBookmarked = false,
    this.rejectionReason,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, [int defaultValue = 0]) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    double parseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return Course(
      courseId: parseInt(json['course_id']),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      instructorUid: json['instructor_uid'] as String,
      categoryId: parseInt(json['category_id']),
      price: parseInt(json['price']),
      level: json['level'] as String,
      discountPrice: parseInt(json['discount_price']),
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      instructorName: json['instructor_name'] as String,
      instructorAvatar: json['instructor_avatar'] as String?,
      categoryName: json['category_name'] as String,
      rating: parseDouble(json['rating']),
      enrollCount: parseInt(json['enroll_count']),
      lessonCount: parseInt(json['lesson_count']),
      totalDuration: json['total_duration'] as String? ?? '00:00:00',
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'course_id': courseId,
    'title': title,
    'description': description,
    'instructor_uid': instructorUid,
    'category_id': categoryId,
    'price': price,
    'level': level,
    'discount_price': discountPrice,
    'thumbnail_url': thumbnailUrl,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'instructor_name': instructorName,
    'instructor_avatar': instructorAvatar,
    'category_name': categoryName,
    'rating': rating,
    'enroll_count': enrollCount,
    'lesson_count': lessonCount,
    'total_duration': totalDuration,
    'is_bookmarked': isBookmarked,
    'rejection_reason': rejectionReason,
  };

  // Tạo bản sao với trạng thái bookmark mới
  Course copyWith({bool? isBookmarked}) {
    return Course(
      courseId: courseId,
      title: title,
      description: description,
      instructorUid: instructorUid,
      categoryId: categoryId,
      price: price,
      level: level,
      discountPrice: discountPrice,
      thumbnailUrl: thumbnailUrl,
      status: status,
      updatedAt: updatedAt,
      instructorName: instructorName,
      instructorAvatar: instructorAvatar,
      categoryName: categoryName,
      rating: rating,
      enrollCount: enrollCount,
      lessonCount: lessonCount,
      totalDuration: totalDuration,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      rejectionReason: rejectionReason,
    );
  }

  // Getter kiểm tra miễn phí
  bool get isFree => price == 0;

  // Hàm hiển thị giá
  String get displayPrice =>
      isFree
          ? 'Miễn phí'
          : '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
}
