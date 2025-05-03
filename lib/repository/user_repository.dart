import 'dart:io';

import 'package:lms/models/user_model.dart';
import 'package:lms/services/user_service.dart';

class UserRepository {
  final UserService _service; // Đảm bảo dùng tên nhất quán
  UserRepository(this._service);

  /* ---------- Lấy thông tin người dùng ---------- */
  Future<User> getUserByUid(String uid) async {
    try {
      return await _service.getUserByUid(uid);
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }

  /* ---------- Cập nhật hồ sơ và nhận thông báo ---------- */
  Future<Map<String, dynamic>> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    File? avatarFile,
  }) async {
    // Gọi service để cập nhật hồ sơ người dùng và nhận thông báo
    final result = await _service.updateProfile(
      uid: uid,
      name: name,
      phone: phone,
      bio: bio,

      avatarFile: avatarFile, // Truyền file nếu có
    );

    if (result['user'] == null) {
      throw Exception('Không thể cập nhật thông tin người dùng');
    }

    return result;
  }

  Future<List<User>> getAllMentors({String? search}) async {
    final raw = await _service.fetchAllMentors(search: search);
    return raw.map((json) {
      // Null-safe mapping
      final safe = {
        'name': json['name'],
        'bio': json['bio'],
        'avatarUrl': json['avatar_url'],
        'phone': json['phone'],
      };
      return User.fromJson(safe);
    }).toList();
  }
}
