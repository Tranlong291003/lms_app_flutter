// src/models/user_model.dart

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
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return User(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      birthdate: parseDate(json['birthdate']),
      role: json['role']?.toString() ?? '',
      fcmToken: json['fcm_token']?.toString() ?? '',
      isActive:
          json['is_active'] is bool
              ? json['is_active']
              : (json['is_active']?.toString().toLowerCase() == 'true'),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
