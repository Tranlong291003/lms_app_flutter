import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/services/base_service.dart';

class MentorRequestService extends BaseService {
  MentorRequestService() : super();

  Future<void> requestMentor({required String userUid, File? imageFile}) async {
    final formData = FormData.fromMap({
      'user_uid': userUid,
      if (imageFile != null)
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
    });
    print(
      '[MentorRequestService] POST /api/mentor-requests, data: user_uid=$userUid, imageFile=${imageFile?.path}',
    );
    try {
      final response = await post(
        ApiConfig.mentorRequest,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      print(
        '[MentorRequestService] Response: ${response.statusCode} - ${response.data}',
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gửi yêu cầu thất bại: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bạn đã gửi yêu cầu rồi, vui lòng thử lại sau nhé');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUpgradeRequests() async {
    print('[MentorRequestService] GET /api/mentor-requests');
    final response = await get(ApiConfig.mentorRequest);
    print(
      '[MentorRequestService] Response: ${response.statusCode} - ${response.data}',
    );
    if (response.statusCode == 200 && response.data is List) {
      return List<Map<String, dynamic>>.from(response.data);
    } else if (response.statusCode == 200 && response.data['data'] is List) {
      return List<Map<String, dynamic>>.from(response.data['data']);
    }
    throw Exception('Không thể lấy danh sách yêu cầu nâng cấp');
  }

  Future<void> updateUpgradeRequestStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    print(
      '[MentorRequestService] PUT /api/mentor-requests/$id/status, status=$status, reason=$reason',
    );
    final response = await put(
      '${ApiConfig.mentorRequest}/$id/status',
      data: {'status': status, 'reason': reason},
    );
    print(
      '[MentorRequestService] Response: ${response.statusCode} - ${response.data}',
    );
    if (response.statusCode != 200) {
      throw Exception('Cập nhật trạng thái thất bại: ${response.statusCode}');
    }
  }
}
