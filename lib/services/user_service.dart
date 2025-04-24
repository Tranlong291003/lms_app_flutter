import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<User> getUserByUid(String uid) async {
    try {
      final response = await _dio.get('${ApiConfig.getUserByUid}/$uid');
      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }
}
