class User {
  final String uid; // Firebase UID làm PK
  final String email; // Email người dùng
  final String? name; // Tên hiển thị
  final String? avatarUrl; // Ảnh đại diện
  final String? bio; // Tiểu sử
  final String? phone; // SĐT
  final String role; // Vai trò: user | mentor | admin
  final bool isActive; // Trạng thái hoạt động
  final DateTime createdAt; // Ngày tạo
  final DateTime? updatedAt; // Ngày cập nhật

  User({
    required this.uid,
    required this.email,
    this.name,
    this.avatarUrl,
    this.bio,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      phone: json['phone'],
      role: json['role'],
      isActive: json['is_active'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'role': role,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
