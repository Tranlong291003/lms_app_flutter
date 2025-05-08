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
      throw Exception('Không thể tải danh sách mentor');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách mentor: $e');
    }
  }

  Future<User> getMentorByUid(String uid) async {
    try {
      final response = await get('${ApiConfig.getUserByUid}/$uid');

      if (response.statusCode == 200) {
        return User.fromJson(response.data['user']);
      }
      throw Exception('Không thể tải thông tin người dùng');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin người dùng: $e');
    }
  }
}
