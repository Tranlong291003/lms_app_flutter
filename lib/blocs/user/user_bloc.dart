import 'package:bloc/bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserLoading()) {
    on<GetUserByUidEvent>(_onGetUserByUid);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
  }

  // Lấy thông tin user từ UID
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

      final result = await _userRepository.updateUserProfile(
        uid: event.uid,
        name: event.name,
        phone: event.phone,
        bio: event.bio,
        gender: event.gender,
        birthdate: event.birthdate,
        avatarFile: event.avatarFile,
      );

      final user = result['user'];
      final notification = result['notification'];

      if (user == null) {
        emit(UserUpdateFailure('Không thể lấy thông tin người dùng'));
        return;
      }

      emit(UserUpdateSuccess(user, notification));
    } catch (e) {
      emit(UserUpdateFailure('Cập nhật hồ sơ thất bại: $e'));
    }
  }
}
