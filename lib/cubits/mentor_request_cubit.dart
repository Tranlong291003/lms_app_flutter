import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/repositories/mentor_request_repository.dart';
import 'package:meta/meta.dart';

part 'mentor_request_state.dart';

class MentorRequestCubit extends Cubit<MentorRequestState> {
  final MentorRequestRepository repository;
  MentorRequestCubit(this.repository) : super(MentorRequestInitial());

  Future<void> sendMentorRequest({
    required String userUid,
    File? imageFile,
  }) async {
    emit(MentorRequestLoading());
    try {
      await repository.sendMentorRequest(
        userUid: userUid,
        imageFile: imageFile,
      );
      emit(MentorRequestSuccess());
    } catch (e) {
      emit(MentorRequestError(e.toString()));
    }
  }

  Future<void> fetchAllUpgradeRequests() async {
    emit(MentorRequestLoading());
    try {
      print('[MentorRequestCubit] Fetching all upgrade requests...');
      final list = await repository.getAllUpgradeRequests();
      print('[MentorRequestCubit] Fetched: $list');
      emit(MentorRequestListLoaded(list));
    } catch (e) {
      print('[MentorRequestCubit] Error fetchAllUpgradeRequests: $e');
      emit(MentorRequestError(e.toString()));
    }
  }

  Future<void> updateUpgradeRequestStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    emit(MentorRequestLoading());
    try {
      print('[MentorRequestCubit] Updating request $id to $status...');
      await repository.updateUpgradeRequestStatus(
        id: id,
        status: status,
        reason: reason,
      );
      print('[MentorRequestCubit] Update success');
      emit(MentorRequestSuccess());
    } catch (e) {
      print('[MentorRequestCubit] Error updateUpgradeRequestStatus: $e');
      emit(MentorRequestError(e.toString()));
    }
  }
}
