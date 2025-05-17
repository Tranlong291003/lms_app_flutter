import 'package:lms/models/user_model.dart';
import 'package:lms/services/admin_user_service.dart';

class AdminUserRepository {
  final AdminUserService _service;

  AdminUserRepository(this._service);

  Future<List<User>> getAllUsers() async {
    return await _service.getAllUsers();
  }

  Future<void> toggleUserStatus(String uid) async {
    await _service.toggleUserStatus(uid);
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _service.updateUserRole(uid, newRole);
  }
}
