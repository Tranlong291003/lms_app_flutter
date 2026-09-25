import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/repositories/admin_user_repository.dart';

part 'admin_user_state.dart';

class AdminUserCubit extends Cubit<AdminUserState> {
  final AdminUserRepository _repository;

  AdminUserCubit(this._repository) : super(AdminUserInitial()) {
    debugPrint(
      '🧩 AdminUserCubit: Initialized with state ${state.runtimeType}',
    );
  }

  /* ---------- Lấy danh sách tất cả người dùng ---------- */
  Future<void> getAllUsers() async {
    debugPrint('🧩 AdminUserCubit: Getting all users');

    // Emit loading state
    debugPrint('🧩 AdminUserCubit: Emitting AdminUserLoading state');
    emit(AdminUserLoading());

    try {
      debugPrint('🧩 AdminUserCubit: Calling repository.getAllUsers()');
      final users = await _repository.getAllUsers();
      debugPrint(
        '🧩 AdminUserCubit: Got ${users.length} users from repository',
      );

      // Emit loaded state with users
      debugPrint('🧩 AdminUserCubit: Emitting AdminUserLoaded state');
      emit(AdminUserLoaded(users));
    } catch (e) {
      if (isClosed) return;
      debugPrint('❌ AdminUserCubit: getAllUsers failed with error: $e');
      emit(AdminUserError(e.toString()));
    }
  }

  /* ---------- Thay đổi trạng thái người dùng ---------- */
  Future<void> toggleUserStatus(String uid, {required String status}) async {
    debugPrint('🧩 AdminUserCubit: Toggling status for user $uid to $status');
    try {
      debugPrint('🧩 AdminUserCubit: Current state: ${state.runtimeType}');
      debugPrint(
        '🧩 AdminUserCubit: Calling repository.toggleUserStatus($uid, $status)',
      );

      await _repository.toggleUserStatus(uid, status: status);

      debugPrint('🧩 AdminUserCubit: Status toggled successfully');
      debugPrint('🧩 AdminUserCubit: Refreshing user list...');
      await getAllUsers();
      debugPrint('🧩 AdminUserCubit: User list refreshed successfully');
    } catch (e) {
      if (isClosed) return;
      debugPrint('❌ AdminUserCubit: toggleUserStatus failed with error: $e');
      debugPrint('❌ AdminUserCubit: Error details:');
      debugPrint('  - User ID: $uid');
      debugPrint('  - Target Status: $status');
      debugPrint('  - Error Type: ${e.runtimeType}');
      debugPrint('  - Error Message: $e');
      debugPrint('❌ AdminUserCubit: Emitting error state');
      emit(AdminUserError(e.toString()));
      // Ném tiếp để nơi gọi biết thao tác thất bại. Nếu chỉ emit rồi nuốt,
      // `await` ở màn hình hoàn tất bình thường và nó báo "thành công" sai.
      rethrow;
    }
  }

  /* ---------- Thay đổi vai trò người dùng ---------- */
  Future<void> updateUserRole(String targetUid, String role) async {
    debugPrint('🧩 AdminUserCubit: Updating role for user $targetUid to $role');
    emit(AdminUserLoading());
    try {
      await _repository.updateUserRole(targetUid, role);
      debugPrint('🧩 AdminUserCubit: Role updated successfully');
      await getAllUsers();
      debugPrint('🧩 AdminUserCubit: User list refreshed after role update');
    } catch (e) {
      if (isClosed) return;
      debugPrint('❌ AdminUserCubit: updateUserRole failed with error: $e');
      emit(AdminUserError(e.toString()));
      rethrow;
    }
  }

  /* ---------- Xoá người dùng ---------- */
  /// `DELETE /api/users/delete/:id` (chỉ admin).
  Future<void> deleteUser(String uid) async {
    debugPrint('🧩 AdminUserCubit: Deleting user $uid');
    emit(AdminUserLoading());
    try {
      await _repository.deleteUser(uid);
      await getAllUsers();
    } catch (e) {
      debugPrint('❌ AdminUserCubit: deleteUser failed with error: $e');
      if (!isClosed) emit(AdminUserError(e.toString()));
      // Ném lại để màn hình không báo "đã xoá" khi máy chủ từ chối.
      rethrow;
    }
  }

  @override
  void onChange(Change<AdminUserState> change) {
    super.onChange(change);
    debugPrint(
      '🧩 AdminUserCubit: State changed from ${change.currentState.runtimeType} to ${change.nextState.runtimeType}',
    );
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    debugPrint('❌ AdminUserCubit: Error occurred: $error');
    super.onError(error, stackTrace);
  }
}
