import 'package:lms/models/notification_model.dart';
import 'package:lms/services/base_service.dart';
import 'package:lms/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  NotificationRepository({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  /// Uid của người dùng đang đăng nhập, đọc từ phiên đã lưu (SharedPreferences).
  String? _sessionUid;

  /// Cho phép tầng gọi truyền uid vào (khuyến nghị) — nếu không truyền thì
  /// repository tự đọc uid từ phiên đã lưu.
  Future<String?> _resolveUid() async {
    _sessionUid ??= await BaseService.readSessionUid();
    return _sessionUid;
  }

  Future<List<NotificationModel>> getNotifications() async {
    final uid = await _resolveUid();
    if (uid == null) return [];
    try {
      return await _notificationService.getNotifications(userUid: uid);
    } catch (e) {
      print('ERROR NotificationRepository: Failed to get notifications: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String notiId) async {
    final uid = await _resolveUid();
    if (uid == null) return;
    try {
      await _notificationService.markAsRead(notiId: notiId, userUid: uid);
    } catch (e) {
      print('ERROR NotificationRepository: Failed to mark as read: $e');
      rethrow;
    }
  }

  Future<void> deleteNotification(String notiId) async {
    final uid = await _resolveUid();
    if (uid == null) return;
    try {
      await _notificationService.deleteNotification(
        notiId: notiId,
        userUid: uid,
      );
    } catch (e) {
      print('ERROR NotificationRepository: Failed to delete notification: $e');
      rethrow;
    }
  }
}
