import 'package:lms/apps/utils/json_parse.dart';

class CourseCategory {
  final int categoryId;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? icon;
  final int courseCount;

  CourseCategory({
    required this.categoryId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.icon,
    this.courseCount = 0,
  });

  /// Tạo từ JSON map (ví dụ lấy từ API)
  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      categoryId: asInt(json['category_id']),
      name: asString(json['name']),
      description: asStringOrNull(json['description']),
      createdAt: asDateTime(json['created_at']),
      updatedAt: asDateTime(json['updated_at']),
      icon: asStringOrNull(json['icon']),
      courseCount: asInt(json['course_count']),
    );
  }

  /// Chuyển sang JSON map để gửi lên API
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'icon': icon,
      'course_count': courseCount,
    };
  }

  @override
  String toString() {
    return 'Category(categoryId: $categoryId, name: $name, '
        'description: $description, createdAt: $createdAt, '
        'updatedAt: $updatedAt, icon: $icon, courseCount: $courseCount)';
  }
}
