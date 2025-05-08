abstract class MentorsEvent {}

class GetAllMentorsEvent extends MentorsEvent {
  final String? search;
  GetAllMentorsEvent({this.search});
}

class GetMentorByUidEvent extends MentorsEvent {
  final String uid;
  GetMentorByUidEvent(this.uid);
}

class RefreshMentorsEvent extends MentorsEvent {}
