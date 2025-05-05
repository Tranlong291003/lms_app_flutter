abstract class MentorsEvent {}

class GetAllMentorsEvent extends MentorsEvent {
  final String? search;
  GetAllMentorsEvent({this.search});
}
