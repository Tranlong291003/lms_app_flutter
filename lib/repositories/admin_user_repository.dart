import 'package:flutter/foundation.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/admin_user_service.dart';

class AdminUserRepository extends BaseRepository<AdminUserService> {
  AdminUserRepository(super.service) {
    debugPrint('📚 AdminUserRepository: Initialized');
  }

  /* ---------- Lấy danh sách tất cả người dùng ---------- */
  Future<List<User>> getAllUsers() async {
    debugPrint('📚 AdminUserRepository: Getting all users');
    try {
      debugPrint('📚 AdminUserRepository: Calling service.getAllUsers()');
      final users = await service.getAllUsers();
      debugPrint(
        '📚 AdminUserRepository: Received ${users.length} users from service',
      );

      // Bạn có thể thêm logic xử lý dữ liệu ở đây nếu cần
      // Ví dụ: lọc ra chỉ người dùng hoạt động, sắp xếp theo tên, v.v.

      return users;
    } catch (e) {
      debugPrint('❌ AdminUserRepository: getAllUsers failed with error: $e');
      throw Exception('Không thể lấy danh sách người dùng: $e');
    }
  }

  /* ---------- Thay đổi trạng thái người dùng ---------- */
  Future<bool> toggleUserStatus(String uid) async {
    debugPrint('📚 AdminUserRepository: Toggling status for user $uid');
    try {
      debugPrint(
        '📚 AdminUserRepository: Calling service.toggleUserStatus($uid)',
      );
      await service.toggleUserStatus(uid);
      debugPrint('📚 AdminUserRepository: Toggle status result: $uid');
      return true;
    } catch (e) {
      debugPrint(
        '❌ AdminUserRepository: toggleUserStatus failed with error: $e',
      );
      throw Exception('Không thể thay đổi trạng thái người dùng: $e');
    }
  }

  // /* ---------- Thay đổi vai trò người dùng ---------- */
  // Future<bool> changeUserRole(String uid, String role) async {
  //   try {
  //     return await service.changeUserRole(uid, role);
  //   } catch (e) {
  //     throw Exception('Không thể thay đổi vai trò người dùng: $e');
  //   }
  // }
}
