import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/app_stats_model.dart';
import 'package:lms/repositories/app_stats_repository.dart';

abstract class AppStatsState {}

class AppStatsInitial extends AppStatsState {}

class AppStatsLoading extends AppStatsState {}

class AppStatsLoaded extends AppStatsState {
  final AppStatsModel stats;
  AppStatsLoaded(this.stats);
}

class AppStatsError extends AppStatsState {
  final String message;
  final bool isRetryable;
  AppStatsError(this.message, {this.isRetryable = true});
}

class AppStatsCubit extends Cubit<AppStatsState> {
  final AppStatsRepository repository;
  static const _maxRetries = 3;
  int _retryCount = 0;

  AppStatsCubit(this.repository) : super(AppStatsInitial());

  Future<void> fetchStats(String uid) async {
    try {
      developer.log(
        'Fetching stats, attempt ${_retryCount + 1}',
        name: 'AppStatsCubit',
      );

      if (_retryCount == 0) {
        emit(AppStatsLoading());
      }

      final stats = await repository.getAppStats(uid);
      _retryCount = 0; // Reset retry count on success
      emit(AppStatsLoaded(stats));

      developer.log('Stats fetched successfully', name: 'AppStatsCubit');
    } catch (e) {
      developer.log('Error fetching stats: $e', name: 'AppStatsCubit');

      _retryCount++;
      final isRetryable = _retryCount < _maxRetries;

      if (isRetryable) {
        developer.log(
          'Retrying... ($_retryCount/$_maxRetries)',
          name: 'AppStatsCubit',
        );
        // Wait a bit before retrying
        await Future.delayed(Duration(seconds: _retryCount));
        fetchStats(uid);
      } else {
        _retryCount = 0; // Reset retry count
        emit(AppStatsError(e.toString(), isRetryable: false));
      }
    }
  }

  void clearCache() {
    repository.clearCache();
    developer.log('Cache cleared', name: 'AppStatsCubit');
  }
}
