class UserModel {
  final int userId;
  final String firebaseUid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String phoneNumber;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.firebaseUid,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.phoneNumber,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // Phương thức từ JSON (nhận dữ liệu từ API)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      firebaseUid: json['firebase_uid'],
      email: json['email'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      role: json['role'],
      isActive: json['is_active'] == 1, // Giả sử 1 = true, 0 = false
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Phương thức chuyển đổi thành JSON (gửi dữ liệu lên API)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'firebase_uid': firebaseUid,
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'phone_number': phoneNumber,
      'role': role,
      'is_active': isActive ? 1 : 0, // true = 1, false = 0
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
