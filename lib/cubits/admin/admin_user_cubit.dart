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
      debugPrint('❌ AdminUserCubit: getAllUsers failed with error: $e');
      emit(AdminUserError(e.toString()));
    }
  }

  /* ---------- Thay đổi trạng thái người dùng ---------- */
  Future<void> toggleUserStatus(String uid) async {
    debugPrint('🧩 AdminUserCubit: Toggling status for user $uid');
    try {
      debugPrint(
        '🧩 AdminUserCubit: Calling repository.toggleUserStatus($uid)',
      );
      await _repository.toggleUserStatus(uid);
      debugPrint(
        '🧩 AdminUserCubit: Status toggled successfully, refreshing user list',
      );
      getAllUsers();
    } catch (e) {
      debugPrint('❌ AdminUserCubit: toggleUserStatus failed with error: $e');
      emit(AdminUserError(e.toString()));
    }
  }

  /* ---------- Thay đổi vai trò người dùng ---------- */
  // Future<void> updateUserRole(String uid, String newRole) async {
  //   try {
  //     await _repository.updateUserRole(uid, newRole);
  //     getAllUsers(); // Refresh the list after update
  //   } catch (e) {
  //     emit(AdminUserError(e.toString()));
  //   }
  // }

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
