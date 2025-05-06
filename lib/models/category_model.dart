class CourseCategory {
  final int categoryId;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? icon;

  CourseCategory({
    required this.categoryId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.icon,
  });

  /// Tạo từ JSON map (ví dụ lấy từ API)
  factory CourseCategory.fromJson(Map<String, dynamic> json) {
    return CourseCategory(
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      icon: json['icon'] as String?,
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
    };
  }

  @override
  String toString() {
    return 'Category(categoryId: $categoryId, name: $name, '
        'description: $description, createdAt: $createdAt, '
        'updatedAt: $updatedAt, icon: $icon)';
  }
}
