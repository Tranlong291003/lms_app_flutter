import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/services/base_service.dart';

class MentorRequestService extends BaseService {
  MentorRequestService() : super();

  /// `POST /api/mentor-requests` — multipart, field `image` **bắt buộc**.
  Future<void> requestMentor({
    required String userUid,
    required File imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'user_uid': userUid,
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await post(
        ApiConfig.mentorRequest,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Gửi yêu cầu thất bại (${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          extractApiError(e, fallback: 'Bạn đã gửi yêu cầu rồi'),
        );
      }
      throw Exception('Gửi yêu cầu thất bại: ${extractApiError(e)}');
    }
  }

  /// `GET /api/mentor-requests` (chỉ admin) → mảng request.
  Future<List<Map<String, dynamic>>> getAllUpgradeRequests() async {
    try {
      final response = await get(ApiConfig.mentorRequest);

      if (response.data is List) {
        return (response.data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      throw Exception('Không thể lấy danh sách yêu cầu nâng cấp');
    } on DioException catch (e) {
      throw Exception(
        'Không thể lấy danh sách yêu cầu nâng cấp: ${extractApiError(e)}',
      );
    }
  }

  /// `PUT /api/mentor-requests/:id/status` (chỉ admin).
  Future<void> updateUpgradeRequestStatus({
    required int id,
    required String status,
    String? reason,
  }) async {
    try {
      final response = await put(
        ApiConfig.mentorRequestStatus(id),
        data: {'status': status, 'reason': reason},
      );
      if (response.statusCode != 200) {
        throw Exception('Cập nhật trạng thái thất bại');
      }
    } on DioException catch (e) {
      throw Exception(
        'Cập nhật trạng thái thất bại: ${extractApiError(e)}',
      );
    }
  }
}
