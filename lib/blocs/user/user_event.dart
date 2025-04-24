// lib/blocs/user/user_event.dart

abstract class UserEvent {}

class GetUserByUidEvent extends UserEvent {
  final String uid;
  GetUserByUidEvent(this.uid);
}

class GetUserByIdEvent extends UserEvent {
  final String userId;
  GetUserByIdEvent(this.userId);
}
