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

  Future<void> toggleUserStatus(String uid) async {
    try {
      await put('${ApiConfig.baseUrl}/api/users/$uid/status');
    } catch (e) {
      throw Exception('Không thể thay đổi trạng thái người dùng: $e');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await put(
      '${ApiConfig.baseUrl}/api/users/$uid/role',
      data: {'role': newRole},
    );
  }
}
