import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/notification_model.dart';
import 'package:lms/services/base_service.dart';

/// Service quản lý thông báo cục bộ và đồng bộ với API.
class NotificationService extends BaseService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo cài đặt cho thông báo cục bộ
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Hiển thị thông báo cục bộ
  Future<void> showNotification(
    String title,
    String body,
    int notificationId,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel',
          'Thông báo mặc định',
          channelDescription: 'Kênh thông báo mặc định cho ứng dụng',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          icon: 'app_icon',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformDetails,
    );
  }

  /// `POST /api/notifications` body `{ uid }` → `{ notifications: [...] }`.
  Future<List<NotificationModel>> getNotifications({
    required String userUid,
  }) async {
    try {
      final response = await post(
        ApiConfig.notifications,
        data: {'uid': userUid},
      );

      if (response.data is Map && response.data['notifications'] is List) {
        return (response.data['notifications'] as List)
            .map(
              (json) => NotificationModel.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Không thể tải thông báo: ${extractApiError(e)}');
    }
  }

  Future<void> markAsRead({
    required String notiId,
    required String userUid,
  }) async {
    try {
      final response = await post(
        ApiConfig.markNotificationRead,
        data: {'uid': userUid, 'noti_id': notiId},
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể đánh dấu thông báo đã đọc');
      }
    } on DioException catch (e) {
      throw Exception(
        'Không thể đánh dấu thông báo đã đọc: ${extractApiError(e)}',
      );
    }
  }

  Future<void> deleteNotification({
    required String notiId,
    required String userUid,
  }) async {
    try {
      final response = await delete(
        ApiConfig.deleteNotification(notiId),
        data: {'uid': userUid},
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể xóa thông báo');
      }
    } on DioException catch (e) {
      throw Exception('Không thể xóa thông báo: ${extractApiError(e)}');
    }
  }
}
