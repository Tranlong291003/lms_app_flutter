import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<GetUserByUidEvent>(_onGetUserByUid);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  // Lấy user theo UID
  Future<void> _onGetUserByUid(
    GetUserByUidEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      final user = await _userRepository.getUserByUid(event.uid);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError('Không thể tải thông tin người dùng: $e'));
    }
  }

  // Cập nhật hồ sơ người dùng
  Future<void> _onUpdateUserProfile(
    UpdateUserProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());

      await _userRepository.updateUserProfile(
        uid: event.uid,
        name: event.name,
        phone: event.phone,
        bio: event.bio,
        avatarFile: event.avatarFile, // 👈 truyền file (có thể null)
      );

      emit(UserUpdateSuccess(message: event.uid));
    } catch (e) {
      emit(UserUpdateFailure('Cập nhật hồ sơ thất bại: $e'));
    }
  }
}
