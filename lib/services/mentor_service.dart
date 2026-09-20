import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/user_model.dart';
import 'package:lms/services/base_service.dart';

class MentorService extends BaseService {
  MentorService({super.token});

  /// `GET /api/users/listmentor` → `{ message, mentors: [...] }`.
  ///
  /// Lưu ý: endpoint này không hỗ trợ tham số `search`; việc tìm kiếm được thực
  /// hiện ở phía client trên danh sách trả về.
  Future<List<Map<String, dynamic>>> fetchAllMentors({String? search}) async {
    try {
      final response = await get(ApiConfig.getAllMentor);

      if (response.data is! Map || response.data['mentors'] is! List) {
        throw Exception('Không thể tải danh sách mentor');
      }

      var mentors = List<Map<String, dynamic>>.from(
        (response.data['mentors'] as List).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      );

      if (search != null && search.trim().isNotEmpty) {
        final keyword = search.trim().toLowerCase();
        mentors = mentors.where((mentor) {
          final name = (mentor['name'] ?? '').toString().toLowerCase();
          final email = (mentor['email'] ?? '').toString().toLowerCase();
          return name.contains(keyword) || email.contains(keyword);
        }).toList();
      }

      return mentors;
    } on DioException catch (e) {
      print('[MentorService] Lỗi khi tải danh sách mentor: ${e.message}');
      throw Exception(
        'Lỗi khi tải danh sách mentor: ${extractApiError(e)}',
      );
    }
  }

  Future<User> getMentorByUid(String uid) async {
    try {
      final response = await get('${ApiConfig.getUserByUid}/$uid');

      if (response.statusCode == 200 && response.data['user'] is Map) {
        return User.fromJson(
          Map<String, dynamic>.from(response.data['user'] as Map),
        );
      }
      throw Exception('Không thể tải thông tin mentor');
    } on DioException catch (e) {
      print('[MentorService] Lỗi khi tải thông tin mentor: ${e.message}');
      throw Exception('Lỗi khi tải thông tin mentor: ${extractApiError(e)}');
    }
  }
}
