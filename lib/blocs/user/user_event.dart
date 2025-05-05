import 'dart:io';

abstract class UserEvent {}

class GetUserByUidEvent extends UserEvent {
  final String uid;
  GetUserByUidEvent(this.uid);
}

class UpdateUserProfileEvent extends UserEvent {
  final String uid;
  final String name;
  final String phone;
  final String bio;
  final String gender; // thêm trường gender
  final DateTime? birthdate; // thêm trường birthdate
  final File? avatarFile; // thêm trường avatarFile

  UpdateUserProfileEvent({
    required this.uid,
    required this.name,
    required this.phone,
    required this.bio,
    required this.gender,
    this.birthdate,
    this.avatarFile,
  });
}
