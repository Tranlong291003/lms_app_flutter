part of 'mentor_request_cubit.dart';

@immutable
abstract class MentorRequestState {}

class MentorRequestInitial extends MentorRequestState {}

class MentorRequestLoading extends MentorRequestState {}

class MentorRequestSuccess extends MentorRequestState {}

class MentorRequestError extends MentorRequestState {
  final String message;
  MentorRequestError(this.message);
}

class MentorRequestListLoaded extends MentorRequestState {
  final List<Map<String, dynamic>> requests;
  MentorRequestListLoaded(this.requests);
}
