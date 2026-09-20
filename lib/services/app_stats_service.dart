import 'dart:developer' as developer;

import 'package:dio/dio.dart';
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
        return AppStatsModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else if (response.statusCode == 403) {
        // Chỉ admin và mentor mới xem được thống kê.
        throw Exception(
          extractApiError(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
            ),
            fallback: 'Bạn không có quyền xem thống kê',
          ),
        );
      } else {
        throw Exception(
          extractApiError(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
            ),
            fallback: 'Lỗi server: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      developer.log('Error in service: $e', name: 'AppStatsService');
      rethrow;
    }
  }
}
