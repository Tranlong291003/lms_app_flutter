import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class UserService extends BaseService {
  UserService({super.token});

  /// Lấy thông tin người dùng theo ID
  Future<User> getUserByUid(String uid) async {
    try {
      final response = await get('${ApiConfig.getUserByUid}/$uid');

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng: $e');
    }
  }

  /// Cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required String gender,
    DateTime? birthdate,
    File? avatarFile,
  }) async {
    try {
      final form = FormData.fromMap({
        'name': name,
        'phone': phone,
        'bio': bio,
        'gender': gender,
        if (birthdate != null) 'birthdate': birthdate.toIso8601String(),
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path),
      });

      final response = await put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: form,
      );

      if (response.statusCode == 200) {
        return {
          'user':
              response.data['user'] != null
                  ? User.fromJson(response.data['user'])
                  : null,
          'notification': response.data['notification'],
        };
      }
      throw Exception('Cập nhật thất bại (${response.statusCode})');
    } catch (e) {
      if (e is DioException) {
        final msg = e.response?.data['message'] ?? 'Không kết nối được server';
        throw Exception('Cập nhật thất bại: $msg');
      }
      throw Exception('Cập nhật thất bại: $e');
    }
  }

  /// Lấy danh sách tất cả người dùng
  Future<List<User>> getAllUsers() async {
    try {
      final response = await get(ApiConfig.getAllUsers);
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['users'];
        return usersJson.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Không thể tải danh sách người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách người dùng: $e');
    }
  }

  Future<bool> checkUserActive(String uid) async {
    try {
      final response = await get(ApiConfig.checkUserActive(uid));
      return response.data['is_active'] as bool;
    } catch (e) {
      rethrow;
    }
  }
}
