import 'package:lms/models/notification_model.dart';
import 'package:lms/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await _notificationService.getNotifications();
    } catch (e) {
      print('ERROR NotificationRepository: Failed to get notifications');
      print('ERROR NotificationRepository: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notiId) async {
    try {
      await _notificationService.markAsRead(notiId);
    } catch (e) {
      print(
        'ERROR NotificationRepository: Failed to mark notification as read',
      );
      print('ERROR NotificationRepository: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notiId) async {
    try {
      await _notificationService.deleteNotification(notiId);
    } catch (e) {
      print('ERROR NotificationRepository: Failed to delete notification');
      print('ERROR NotificationRepository: $e');
      rethrow;
    }
  }
}
