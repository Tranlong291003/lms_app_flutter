abstract class UserEvent {}

class GetUserByUidEvent extends UserEvent {
  final String uid;
  GetUserByUidEvent(this.uid);
}

class UpdateUserProfileEvent extends UserEvent {
  final String uid;
  final String? name;
  final String? avatarUrl;
  final String? bio;
  final String? phone;

  UpdateUserProfileEvent({
    required this.uid,
    this.name,
    this.avatarUrl,
    this.bio,
    this.phone,
  });
}
