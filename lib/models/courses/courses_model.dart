// lib/models/courses/course_model.dart
import 'package:lms/apps/utils/json_parse.dart';

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
        total: asInt(json['total']),
      );
    }

    if (data is! Map) {
      print(
        '[CourseListResponse] Data is not a Map: ${data.runtimeType}',
      );
      return CourseListResponse(
        pending: [],
        approved: [],
        rejected: [],
        total: asInt(json['total']),
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
      total: asInt(json['total']),
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
    return Course(
      courseId: asInt(json['course_id']),
      title: asString(json['title']),
      description: asString(json['description']),
      instructorUid: asString(json['instructor_uid']),
      categoryId: asInt(json['category_id']),
      price: asInt(json['price']),
      level: asString(json['level']),
      discountPrice: asInt(json['discount_price']),
      thumbnailUrl: asStringOrNull(json['thumbnail_url']),
      status: asString(json['status'], 'pending'),
      updatedAt: asDateTimeOr(
        json['updated_at'] ?? json['created_at'],
        DateTime.fromMillisecondsSinceEpoch(0),
      ),
      instructorName: asString(json['instructor_name']),
      instructorAvatar: asStringOrNull(json['instructor_avatar']),
      categoryName: asString(json['category_name']),
      rating: asDouble(json['rating']),
      enrollCount: asInt(json['enroll_count']),
      lessonCount: asInt(json['lesson_count']),
      totalDuration: asString(json['total_duration'], '00:00:00'),
      isBookmarked: asBool(json['is_bookmarked']),
      rejectionReason: asStringOrNull(json['rejection_reason']),
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
