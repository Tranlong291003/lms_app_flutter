// lib/models/user_model.dart

import 'package:lms/apps/utils/json_parse.dart';

class User {
  final String uid;
  final String email;
  final String name;
  final String avatarUrl;
  final String bio;
  final String phone;
  final String gender;
  final DateTime? birthdate;
  final String role;
  final String fcmToken;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.uid,
    required this.email,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.phone,
    required this.gender,
    this.birthdate,
    required this.role,
    required this.fcmToken,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: asString(json['uid']),
      email: asString(json['email']),
      name: asString(json['name']),
      avatarUrl: asString(json['avatar_url']),
      bio: asString(json['bio']),
      phone: asString(json['phone']),
      gender: asString(json['gender']),
      birthdate: asDateTime(json['birthdate']),
      role: asString(json['role']),
      fcmToken: asString(json['fcm_token']),
      // Thiếu trường KHÔNG có nghĩa là tài khoản bị khoá. `GET /api/users/:id`
      // (hồ sơ công khai) không trả `is_active`; nếu mặc định false thì mọi
      // mentor đều hiển thị "Không hoạt động". Khi cần biết chắc trạng thái của
      // chính mình, dùng `/api/auth/me` hoặc `checkUserActive`.
      isActive: json.containsKey('is_active') ? asBool(json['is_active']) : true,
      createdAt: asDateTime(json['created_at']),
      updatedAt: asDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatDate(DateTime? date) => date?.toIso8601String();

    return {
      'uid': uid,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone': phone,
      'gender': gender,
      'birthdate': formatDate(birthdate),
      'role': role,
      'fcm_token': fcmToken,
      'is_active': isActive,
      'created_at': formatDate(createdAt),
      'updated_at': formatDate(updatedAt),
    };
  }
}
