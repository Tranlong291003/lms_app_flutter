import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class AdminUserService extends BaseService {
  AdminUserService() : super();

  /// `GET /api/users` (chỉ admin) → `{ message, users: [...] }`
  Future<List<User>> getAllUsers() async {
    try {
      final response = await get(ApiConfig.getAllUsers);
      final data = response.data;

      if (data is Map && data['users'] is List) {
        return (data['users'] as List)
            .map((json) => User.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      if (data is List) {
        return data
            .map((json) => User.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      throw Exception('Format dữ liệu không hợp lệ');
    } catch (e) {
      throw Exception(
        'Không thể lấy danh sách người dùng: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// `PATCH /api/users/:id/status` body `{ status: "active" | "disabled" }`.
  Future<void> toggleUserStatus(String uid, {required String status}) async {
    try {
      await patch(ApiConfig.updateUserStatus(uid), data: {'status': status});
    } catch (e) {
      debugPrint('AdminUserService: toggleUserStatus lỗi: $e');
      throw Exception(
        'Không thể thay đổi trạng thái người dùng: '
        '${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// `PUT /api/users/updaterole` body `{ uid, role }` (chỉ admin).
  Future<void> updateUserRole(String targetUid, String role) async {
    try {
      final response = await put(
        ApiConfig.updateUserRole,
        data: {'uid': targetUid, 'role': role},
      );
      if (response.statusCode != 200) {
        throw Exception('Cập nhật vai trò thất bại');
      }
    } catch (e) {
      throw Exception(
        'Không thể cập nhật vai trò: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// `DELETE /api/users/delete/:id` (chỉ admin).
  Future<void> deleteUser(String uid) async {
    try {
      final response = await delete(ApiConfig.deleteUserById(uid));
      if (response.statusCode != 200) {
        throw Exception('Xóa người dùng thất bại');
      }
    } on DioException catch (e) {
      // 409: người dùng còn dữ liệu liên quan (khóa học, đánh giá...).
      if (e.response?.statusCode == 409) {
        throw Exception(
          extractApiError(
            e,
            fallback: 'Không thể xóa: người dùng còn dữ liệu liên quan',
          ),
        );
      }
      throw Exception('Xóa người dùng thất bại: ${extractApiError(e)}');
    }
  }
}
