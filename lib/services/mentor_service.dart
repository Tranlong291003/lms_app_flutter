import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';

class MentorService {
  final Dio _dio;
  MentorService(this._dio);

  Future<List<Map<String, dynamic>>> fetchAllMentors({String? search}) async {
    try {
      final res = await _dio.get(
        ApiConfig.getAllMentor,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      if (res.statusCode == 200 && res.data['mentors'] is List) {
        print('object');
        return List<Map<String, dynamic>>.from(res.data['mentors']);
      }
      throw Exception('Không thể tải danh sách mentor');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách mentor: \$e');
    }
  }
}
