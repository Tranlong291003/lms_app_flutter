// lib/blocs/user/user_state.dart

import 'package:lms/models/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}
