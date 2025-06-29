import 'dart:io';

import 'package:lms/models/user_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/user_service.dart';

class UserRepository extends BaseRepository<UserService> {
  UserRepository(super.service);

  /* ---------- Lấy thông tin người dùng ---------- */
  Future<User> getUserByUid(String uid) async {
    try {
      return await service.getUserByUid(uid);
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
    required String gender,
    DateTime? birthdate,
    File? avatarFile,
  }) async {
    // Gọi service để cập nhật hồ sơ người dùng và nhận thông báo
    final result = await service.updateProfile(
      uid: uid,
      name: name,
      phone: phone,
      bio: bio,
      gender: gender,
      birthdate: birthdate,
      avatarFile: avatarFile,
    );

    if (result['user'] == null) {
      throw Exception('Không thể cập nhật thông tin người dùng');
    }

    return result;
  }

  /* ---------- Lấy danh sách tất cả người dùng ---------- */
  Future<List<User>> getAllUsers() async {
    try {
      return await service.getAllUsers();
    } catch (e) {
      throw Exception('Không thể lấy danh sách người dùng: $e');
    }
  }
}
