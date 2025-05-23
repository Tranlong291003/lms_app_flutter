import 'dart:developer' as developer;

import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/app_stats_model.dart';
import 'package:lms/services/base_service.dart';

class AppStatsService extends BaseService {
  AppStatsService() : super();

  Future<AppStatsModel> fetchAppStats({required String uid}) async {
    try {
      developer.log(
        'Fetching app stats for uid: $uid',
        name: 'AppStatsService',
      );

      final response = await post(ApiConfig.appStats, data: {'uid': uid});

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'AppStatsService',
      );
      developer.log('Response data: ${response.data}', name: 'AppStatsService');

      if (response.statusCode == 200) {
        return AppStatsModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception(
          'API endpoint không tồn tại. Vui lòng kiểm tra lại URL.',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in service: $e', name: 'AppStatsService');
      rethrow;
    }
  }
}
