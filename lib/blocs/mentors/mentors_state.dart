import 'package:flutter/material.dart';
import 'package:lms/models/user_model.dart';

@immutable
abstract class MentorsState {}

class MentorsLoading extends MentorsState {}

class MentorsLoaded extends MentorsState {
  final List<User> mentors;
  MentorsLoaded(this.mentors);
}

class MentorsError extends MentorsState {
  final String message;
  MentorsError(this.message);
}
