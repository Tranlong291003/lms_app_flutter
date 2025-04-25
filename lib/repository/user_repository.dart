/// lib/repository/user_repository.dart
library;

import 'dart:io';

import 'package:lms/models/user_model.dart';
import 'package:lms/services/user_service.dart';

class UserRepository {
  final UserService _service; // đổi tên nhất quán
  UserRepository(this._service);

  /* ---------- Lấy thông tin người dùng ---------- */
  Future<User> getUserByUid(String uid) async {
    try {
      return await _service.getUserByUid(uid);
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }

  /* ---------- Cập nhật hồ sơ (tự quyết định gửi file hay không) ---------- */
  Future<User> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    File? avatarFile, // null = không đổi ảnh
  }) {
    return avatarFile == null
        // 1️⃣ chỉ gửi text – server giữ avatar cũ
        ? _service.updateProfile(
          uid: uid,
          name: name,
          phone: phone,
          bio: bio,
          avatarUrl: '', // chuỗi rỗng → server bỏ qua
        )
        // 2️⃣ gửi multipart – file + text
        : _service.multipartUpdateProfile(
          uid: uid,
          name: name,
          phone: phone,
          bio: bio,
          avatarFile: avatarFile,
        );
  }
}
