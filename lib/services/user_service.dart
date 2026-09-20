import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class UserService extends BaseService {
  UserService({super.token});

  /// Lấy thông tin người dùng theo ID
  Future<User> getUserByUid(String uid) async {
    try {
      final response = await get('${ApiConfig.getUserByUid}/$uid');

      if (response.statusCode == 200 && response.data['user'] is Map) {
        return User.fromJson(
          Map<String, dynamic>.from(response.data['user'] as Map),
        );
      }
      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      throw Exception(
        'Lỗi khi tải thông tin người dùng: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// Cập nhật thông tin người dùng (`PUT /api/users/update/:id`, multipart).
  ///
  /// `birthdate` phải theo định dạng `YYYY-MM-DD` — backend đưa thẳng vào
  /// `new Date(...)` nên chuỗi ISO đầy đủ cũng chấp nhận được, nhưng dùng dạng
  /// ngày cho đúng contract.
  Future<Map<String, dynamic>> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String bio,
    required String gender,
    DateTime? birthdate,
    File? avatarFile,
  }) async {
    try {
      final fields = <String, dynamic>{
        'name': name,
        'phone': phone,
        'bio': bio,
        'gender': gender,
        if (birthdate != null) 'birthdate': formatBirthdate(birthdate),
      };

      // Chỉ gửi file khi người dùng thực sự chọn ảnh mới, nếu không server sẽ
      // ghi đè avatar bằng file rỗng.
      if (avatarFile != null) {
        final fileName = avatarFile.path.split(Platform.pathSeparator).last;
        fields['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: fileName,
        );
      }

      final response = await put(
        '${ApiConfig.updateUserByUid}/$uid',
        data: FormData.fromMap(fields),
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        return {
          'user':
              response.data['user'] != null
                  ? User.fromJson(
                    Map<String, dynamic>.from(response.data['user'] as Map),
                  )
                  : null,
          'notification': response.data['notification'],
        };
      }
      throw Exception('Cập nhật thất bại (${response.statusCode})');
    } catch (e) {
      throw Exception(
        'Cập nhật thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// Định dạng ngày sinh theo `YYYY-MM-DD` mà API mong đợi.
  static String formatBirthdate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Lấy danh sách tất cả người dùng (chỉ admin).
  Future<List<User>> getAllUsers() async {
    try {
      final response = await get(ApiConfig.getAllUsers);
      if (response.statusCode == 200 && response.data['users'] is List) {
        final List<dynamic> usersJson = response.data['users'];
        return usersJson
            .map((json) => User.fromJson(Map<String, dynamic>.from(json as Map)))
            .toList();
      }
      throw Exception('Không thể tải danh sách người dùng');
    } catch (e) {
      throw Exception(
        'Lỗi khi tải danh sách người dùng: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  Future<bool> checkUserActive(String uid) async {
    try {
      final response = await get(ApiConfig.checkUserActive(uid));
      return response.data['is_active'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
