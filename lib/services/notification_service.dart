import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Khởi tạo các cài đặt cho thông báo cục bộ
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          'app_icon',
        ); // Đảm bảo bạn có icon trong drawable

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Hàm để hiển thị thông báo cục bộ
  Future<void> showNotification(
    String title,
    String body,
    int notificationId,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id', // Channel ID
          'your_channel_name',
          channelDescription: 'Your channel description',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: false,
          icon: 'app_icon', // Đặt tên icon mà bạn đã thêm vào thư mục drawable
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Hiển thị thông báo
    await flutterLocalNotificationsPlugin.show(
      notificationId, // ID thông báo
      title, // Tiêu đề thông báo
      body, // Nội dung thông báo
      platformDetails,
    );
  }
}
