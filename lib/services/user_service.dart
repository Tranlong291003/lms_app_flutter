import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';

class UserService {
  final Dio _dio;
  UserService(this._dio);

  /* ───────────────── GET USER BY ID ───────────────── */
  Future<User> getUserByUid(String uid) async {
    try {
      final res = await _dio.get('${ApiConfig.getUserByUid}/$uid');
      if (res.statusCode == 200) {
        // print('object');

        return User.fromJson(res.data['user']);
      }

      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  /* ───────────────── UPDATE PROFILE ───────────────── */
  Future<Map<String, dynamic>> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required String gender,
    DateTime? birthdate,
    File? avatarFile, // Ảnh đại diện, có thể null
  }) async {
    try {
      // Format birthdate thành ISO string nếu có
      final birthdateStr = birthdate?.toIso8601String();

      // Tạo FormData với các field mới
      FormData form = FormData.fromMap({
        'name': name,
        'phone': phone,
        'bio': bio,
        'gender': gender,
        if (birthdateStr != null) 'birthdate': birthdateStr,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path),
      });

      final res = await _dio.put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: form,
      );

      if (res.statusCode == 200) {
        return {
          'user':
              res.data['user'] != null ? User.fromJson(res.data['user']) : null,
          'notification': res.data['notification'],
        };
      } else {
        throw Exception('Cập nhật thất bại (${res.statusCode})');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Không kết nối được server';
      throw Exception('Cập nhật thất bại: $msg');
    }
  }
}
