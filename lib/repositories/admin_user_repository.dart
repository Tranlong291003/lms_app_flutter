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
  Future<bool> toggleUserStatus(String uid, {required String status}) async {
    debugPrint(
      '📚 AdminUserRepository: Toggling status for user $uid to $status',
    );
    try {
      debugPrint(
        '📚 AdminUserRepository: Calling service.toggleUserStatus($uid, $status)',
      );
      await service.toggleUserStatus(uid, status: status);
      debugPrint(
        '📚 AdminUserRepository: Toggle status successful for user $uid',
      );
      return true;
    } catch (e) {
      debugPrint(
        '❌ AdminUserRepository: toggleUserStatus failed with error: $e',
      );
      debugPrint('❌ AdminUserRepository: Error details:');
      debugPrint('  - User ID: $uid');
      debugPrint('  - Target Status: $status');
      debugPrint('  - Error Type: ${e.runtimeType}');
      debugPrint('  - Error Message: $e');
      throw Exception('Không thể thay đổi trạng thái người dùng: $e');
    }
  }

  /* ---------- Thay đổi vai trò người dùng ---------- */
  Future<void> updateUserRole(String targetUid, String role) async {
    debugPrint(
      '📚 AdminUserRepository: Updating role for user $targetUid to $role',
    );
    try {
      await service.updateUserRole(targetUid, role);
      debugPrint(
        '📚 AdminUserRepository: Update role successful for user $targetUid',
      );
    } catch (e) {
      debugPrint('❌ AdminUserRepository: updateUserRole failed with error: $e');
      throw Exception('Không thể cập nhật vai trò người dùng: $e');
    }
  }

  /* ---------- Xoá người dùng ---------- */
  /// `DELETE /api/users/delete/:id` (chỉ admin).
  ///
  /// `AdminUserService.deleteUser` đã có sẵn nhưng chưa từng được nối ra UI,
  /// nên admin không thực hiện được thao tác mà API vẫn hỗ trợ.
  Future<void> deleteUser(String uid) async {
    debugPrint('📚 AdminUserRepository: Deleting user $uid');
    try {
      await service.deleteUser(uid);
    } catch (e) {
      debugPrint('❌ AdminUserRepository: deleteUser failed with error: $e');
      // Giữ nguyên thông điệp đã xử lý ở tầng service (409 → còn dữ liệu liên
      // quan) thay vì bọc thêm một lớp "Exception:".
      rethrow;
    }
  }
}
