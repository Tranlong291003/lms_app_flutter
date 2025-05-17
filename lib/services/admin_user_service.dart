import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class AdminUserService extends BaseService {
  AdminUserService() : super();

  Future<List<User>> getAllUsers() async {
    final response = await get('${ApiConfig.baseUrl}/api/users');
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<void> toggleUserStatus(String uid) async {
    await put('${ApiConfig.baseUrl}/api/users/$uid/status');
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await put(
      '${ApiConfig.baseUrl}/api/users/$uid/role',
      data: {'role': newRole},
    );
  }
}
