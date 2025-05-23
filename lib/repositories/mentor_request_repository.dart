import 'dart:io';

import 'package:lms/services/mentor_request_service.dart';

class MentorRequestRepository {
  final MentorRequestService service;
  MentorRequestRepository(this.service);

  Future<void> sendMentorRequest({required String userUid, File? imageFile}) {
    return service.requestMentor(userUid: userUid, imageFile: imageFile);
  }

  Future<List<Map<String, dynamic>>> getAllUpgradeRequests() async {
    print('[MentorRequestRepository] Gọi getAllUpgradeRequests');
    final result = await service.getAllUpgradeRequests();
    print('[MentorRequestRepository] Kết quả: $result');
    return result;
  }

  Future<void> updateUpgradeRequestStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    print(
      '[MentorRequestRepository] Gọi updateUpgradeRequestStatus: id=$id, status=$status, reason=$reason',
    );
    await service.updateUpgradeRequestStatus(
      id: id,
      status: status,
      reason: reason,
    );
    print('[MentorRequestRepository] Đã cập nhật trạng thái thành công');
  }
}
