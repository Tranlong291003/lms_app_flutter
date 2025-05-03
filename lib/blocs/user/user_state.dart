import 'package:flutter/material.dart';
import 'package:lms/models/user_model.dart';

@immutable
abstract class UserState {}

class UserUpdateSuccess extends UserState {
  final User user;
  final Map<String, dynamic> notification;

  UserUpdateSuccess(this.user, this.notification);
}

class UserUpdateFailure extends UserState {
  final String message;

  UserUpdateFailure(this.message);
}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  UserLoaded(this.user);
}

class UserError extends UserState {
  final String message;

  UserError(this.message);
}

class MentorsLoading extends UserState {}

class MentorsLoaded extends UserState {
  final List<User> mentors;
  MentorsLoaded(this.mentors);
}

class MentorsError extends UserState {
  final String message;
  MentorsError(this.message);
}
