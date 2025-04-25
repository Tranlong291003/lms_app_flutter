import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  // Lấy thông tin người dùng
  Future<User> getUserByUid(String uid) async {
    try {
      final response = await _dio.get('${ApiConfig.getUserByUid}/$uid');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Không thể tải thông tin người dùng');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi khi tải thông tin người dùng: $e');
    }
  }

  // Cập nhật hồ sơ người dùng
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? avatarUrl,
    String? bio,
    String? phone,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: {
          'name': name,
          'avatar_url': avatarUrl,
          'bio': bio,
          'phone': phone,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Cập nhật hồ sơ thất bại. Mã lỗi: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      final errMsg =
          e.response?.data['message'] ?? 'Không thể kết nối đến máy chủ';
      throw Exception('Cập nhật hồ sơ thất bại: $errMsg');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi không xác định: $e');
    }
  }
}
