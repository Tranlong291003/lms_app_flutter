import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class AdminUserService extends BaseService {
  AdminUserService() : super();

  Future<List<User>> getAllUsers() async {
    try {
      final response = await get('${ApiConfig.baseUrl}/api/users');
      final data = response.data;

      // Parse response data
      if (data is Map<String, dynamic>) {
        if (data['users'] is List) {
          return (data['users'] as List)
              .map((json) => User.fromJson(json))
              .toList();
        } else if (data['data'] is Map && data['data']['users'] is List) {
          return (data['data']['users'] as List)
              .map((json) => User.fromJson(json))
              .toList();
        }
      } else if (data is List) {
        return data.map((json) => User.fromJson(json)).toList();
      }

      throw Exception('Format dữ liệu không hợp lệ');
    } catch (e) {
      throw Exception('Không thể lấy danh sách người dùng: $e');
    }
  }

  Future<void> toggleUserStatus(String uid, {required String status}) async {
    debugPrint('🔍 AdminUserService: Toggling status for user $uid to $status');
    try {
      final url = '${ApiConfig.baseUrl}/api/users/$uid/status';
      debugPrint('🔍 AdminUserService: Making PUT request to $url');
      debugPrint('🔍 AdminUserService: Request body: {"status": "$status"}');

      final response = await patch(url, data: {'status': status});

      debugPrint(
        '🔍 AdminUserService: Response status code: ${response.statusCode}',
      );
      debugPrint('🔍 AdminUserService: Response data: ${response.data}');
    } catch (e) {
      debugPrint('❌ AdminUserService: toggleUserStatus failed with error: $e');
      if (e is DioException) {
        debugPrint('❌ AdminUserService: DioException details:');
        debugPrint('  - Type: ${e.type}');
        debugPrint('  - Message: ${e.message}');
        debugPrint('  - Response: ${e.response?.data}');
        debugPrint('  - Request: ${e.requestOptions.uri}');
        debugPrint('  - Headers: ${e.requestOptions.headers}');
      }
      throw Exception('Không thể thay đổi trạng thái người dùng: $e');
    }
  }

  Future<void> updateUserRole(String targetUid, String role) async {
    try {
      final url = '${ApiConfig.baseUrl}/api/users/updaterole';
      final body = {'targetUid': targetUid, 'role': role};
      final response = await put(url, data: body);
      if (response.statusCode != 200) {
        throw Exception('Cập nhật vai trò thất bại: ${response.data}');
      }
    } catch (e) {
      throw Exception('Không thể cập nhật vai trò: $e');
    }
  }
}
