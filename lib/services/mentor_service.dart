import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class MentorService extends BaseService {
  MentorService({super.token});

  /// Lấy danh sách mentor với tùy chọn tìm kiếm
  Future<List<Map<String, dynamic>>> fetchAllMentors({String? search}) async {
    try {
      final response = await get(
        ApiConfig.getAllMentor,
        queryParameters: {if (search?.isNotEmpty ?? false) 'search': search},
      );

      if (response.statusCode == 200 && response.data['mentors'] is List) {
        return List<Map<String, dynamic>>.from(response.data['mentors']);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error:
            'Không thể tải danh sách mentor: Mã trạng thái ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        print('[MentorService] Lỗi Dio khi tải danh sách mentor: ${e.message}');
        if (e.response != null) {
          print('[MentorService] Response data: ${e.response?.data}');
        }
        throw Exception('Lỗi tải danh sách mentor: ${e.message}');
      } else {
        print(
          '[MentorService] Lỗi không xác định khi tải danh sách mentor: $e',
        );
        throw Exception('Lỗi khi tải danh sách mentor: $e');
      }
    }
  }

  Future<User> getMentorByUid(String uid) async {
    try {
      final response = await get('${ApiConfig.getUserByUid}/$uid');

      if (response.statusCode == 200 &&
          response.data['user'] is Map<String, dynamic>) {
        return User.fromJson(response.data['user']);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error:
            'Không thể tải thông tin người dùng: Mã trạng thái ${response.statusCode}',
      );
    } catch (e) {
      if (e is DioException) {
        print(
          '[MentorService] Lỗi Dio khi tải thông tin người dùng: ${e.message}',
        );
        if (e.response != null) {
          print('[MentorService] Response data: ${e.response?.data}');
        }
        throw Exception('Lỗi tải thông tin người dùng: ${e.message}');
      } else {
        print(
          '[MentorService] Lỗi không xác định khi tải thông tin người dùng: $e',
        );
        throw Exception('Lỗi khi tải thông tin người dùng: $e');
      }
    }
  }
}
