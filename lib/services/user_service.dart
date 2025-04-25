/// lib/services/user_service.dart
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';

class UserService {
  final Dio _dio;
  UserService(this._dio);

  /* ───────────────── GET USER ───────────────── */
  Future<User> getUserByUid(String uid) async {
    try {
      final res = await _dio.get('${ApiConfig.getUserByUid}/$uid');
      if (res.statusCode == 200) {
        return User.fromJson(res.data['data']);
      }
      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  /* ──────────────── (A) UPDATE CHỈ TEXT ──────────────── */
  Future<User> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required String avatarUrl, // truyền "" nếu giữ ảnh cũ
  }) async {
    try {
      final res = await _dio.put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: {
          'name': name,
          'phone': phone,
          'bio': bio,
          'avatar': avatarUrl, // rỗng ⇒ backend bỏ qua
        },
      );
      if (res.statusCode == 200) {
        return User.fromJson(res.data['data']);
      }
      throw Exception('Cập nhật thất bại (${res.statusCode})');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Không kết nối được server';
      throw Exception('Cập nhật thất bại: $msg');
    }
  }

  /* ──────────── (B) UPDATE TEXT + FILE (MULTIPART) ──────────── */
  Future<User> multipartUpdateProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required File avatarFile,
  }) async {
    try {
      final form = FormData.fromMap({
        'name': name,
        'phone': phone,
        'bio': bio,
        'avatar': await MultipartFile.fromFile(
          avatarFile.path,
          filename: avatarFile.path.split('/').last,
        ),
      });

      final res = await _dio.put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: form,
      );

      if (res.statusCode == 200) {
        return User.fromJson(res.data['data']);
      }
      throw Exception('Multipart cập nhật thất bại (${res.statusCode})');
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Không kết nối được server';
      throw Exception('Multipart cập nhật thất bại: $msg');
    }
  }
}
