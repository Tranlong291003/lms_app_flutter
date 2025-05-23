import 'dart:developer' as developer;

import 'package:lms/models/app_stats_model.dart';
import 'package:lms/services/app_stats_service.dart';

class AppStatsRepository {
  final AppStatsService _service;
  AppStatsModel? _cachedStats;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  AppStatsRepository(this._service);

  Future<AppStatsModel> getAppStats(String uid) async {
    try {
      developer.log(
        'Getting app stats for uid: $uid',
        name: 'AppStatsRepository',
      );

      // Check cache
      if (_cachedStats != null && _lastFetchTime != null) {
        final now = DateTime.now();
        if (now.difference(_lastFetchTime!) < _cacheDuration) {
          developer.log('Returning cached stats', name: 'AppStatsRepository');
          return _cachedStats!;
        }
      }

      // Fetch fresh data
      developer.log('Fetching fresh stats', name: 'AppStatsRepository');
      final stats = await _service.fetchAppStats(uid: uid);

      // Update cache
      _cachedStats = stats;
      _lastFetchTime = DateTime.now();

      return stats;
    } catch (e) {
      developer.log('Error in repository: $e', name: 'AppStatsRepository');
      // If we have cached data, return it even if expired
      if (_cachedStats != null) {
        developer.log(
          'Returning expired cached stats',
          name: 'AppStatsRepository',
        );
        return _cachedStats!;
      }
      throw Exception('Lỗi lấy thống kê: $e');
    }
  }

  void clearCache() {
    _cachedStats = null;
    _lastFetchTime = null;
    developer.log('Cache cleared', name: 'AppStatsRepository');
  }
}
