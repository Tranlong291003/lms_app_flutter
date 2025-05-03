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
  final File? avatarFile; //  thêm dòng này

  UpdateUserProfileEvent({
    required this.uid,
    required this.name,
    required this.phone,
    required this.bio,
    this.avatarFile, //  thêm dòng này
  });
}

class GetAllMentorsEvent extends UserEvent {
  final String? search;
  GetAllMentorsEvent({this.search});
}
