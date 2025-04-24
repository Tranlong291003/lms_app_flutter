// lib/blocs/user/user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/repository/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(UserInitial()) {
    on<GetUserByUidEvent>(_onGetUserByUid);
  }

  Future<void> _onGetUserByUid(
    GetUserByUidEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoading());
      final user = await _userRepository.getUserByUid(event.uid);
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
