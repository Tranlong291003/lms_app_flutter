import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/notification_model.dart';
import 'package:lms/services/base_service.dart';

/// Service quản lý thông báo cục bộ
class NotificationService extends BaseService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Khởi tạo cài đặt cho thông báo cục bộ
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

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

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await post(
        '${ApiConfig.baseUrl}/api/notifications',
        data: {'uid': currentUser.uid},
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsData =
            response.data['notifications'] ?? [];
        return notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notiId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await post(
        '${ApiConfig.baseUrl}/api/notifications/mark-read',
        data: {'uid': currentUser.uid, 'noti_id': notiId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notiId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await delete(
        '${ApiConfig.baseUrl}/api/notifications/delete/$notiId',
        data: {'uid': currentUser.uid},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }
}
