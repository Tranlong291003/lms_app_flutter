part of 'admin_user_cubit.dart';

abstract class AdminUserState {}

class AdminUserInitial extends AdminUserState {}

class AdminUserLoading extends AdminUserState {}

class AdminUserLoaded extends AdminUserState {
  final List<User> users;
  AdminUserLoaded(this.users);
}

class AdminUserError extends AdminUserState {
  final String message;
  AdminUserError(this.message);
}
