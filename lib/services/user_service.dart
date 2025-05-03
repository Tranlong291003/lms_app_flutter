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
    File? avatarFile, // Ảnh đại diện, có thể null
  }) async {
    try {
      FormData form = FormData.fromMap({
        'name': name,
        'phone': phone,
        'bio': bio,
        if (avatarFile != null)
          'avatar': await MultipartFile.fromFile(avatarFile.path),
      });

      final res = await _dio.put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: form,
      );

      if (res.statusCode == 200) {
        // Đảm bảo rằng 'user' và 'notification' không phải là null
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

  /* ───────────────── GET ALL MENTORS ───────────────── */
  Future<List<Map<String, dynamic>>> fetchAllMentors({String? search}) async {
    try {
      final res = await _dio.get(
        ApiConfig.getAllMentor,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      if (res.statusCode == 200 && res.data['mentors'] is List) {
        return List<Map<String, dynamic>>.from(res.data['mentors']);
      }
      throw Exception('Không thể tải danh sách mentor');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách mentor: \$e');
    }
  }
}
