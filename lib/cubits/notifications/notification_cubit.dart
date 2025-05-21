import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/notifications/notification_state.dart';
import 'package:lms/repositories/notification_repository.dart';
import 'package:lms/services/notification_service.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;
  final NotificationService? _notificationService;

  NotificationCubit({
    NotificationRepository? notificationRepository,
    NotificationService? notificationService,
  }) : _notificationRepository =
           notificationRepository ?? NotificationRepository(),
       _notificationService = notificationService,
       super(NotificationInitial());

  Future<void> loadNotifications() async {
    try {
      emit(NotificationLoading());
      final notifications = await _notificationRepository.getNotifications();
      emit(NotificationLoaded(notifications));
    } catch (e) {
      print('ERROR NotificationCubit: Failed to load notifications');
      print('ERROR NotificationCubit: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAsRead(String notiId) async {
    try {
      await _notificationRepository.markAsRead(notiId);
      await loadNotifications(); // Reload notifications after marking as read
    } catch (e) {
      print('ERROR NotificationCubit: Failed to mark notification as read');
      print('ERROR NotificationCubit: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> deleteNotification(String notiId) async {
    try {
      await _notificationRepository.deleteNotification(notiId);
      await loadNotifications(); // Reload notifications after deletion
    } catch (e) {
      print('ERROR NotificationCubit: Failed to delete notification');
      print('ERROR NotificationCubit: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      if (state is NotificationLoaded) {
        final notifications = (state as NotificationLoaded).notifications;
        // Gọi service/repository nếu có API, ở đây giả lập local
        final updated =
            notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(NotificationLoaded(updated));
      }
    } catch (e) {
      emit(NotificationError('Không thể đánh dấu tất cả là đã đọc'));
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      // Gọi service/repository nếu có API, ở đây giả lập local
      emit(NotificationLoaded([]));
    } catch (e) {
      emit(NotificationError('Không thể xoá tất cả thông báo'));
    }
  }

  // Hàm để hiển thị thông báo cục bộ
  Future<void> showNotification(
    String title,
    String body,
    int notificationId,
  ) async {
    try {
      emit(NotificationLoading());
      if (_notificationService != null) {
        await _notificationService.showNotification(
          title,
          body,
          notificationId,
        );
        emit(NotificationSuccess());
      } else {
        emit(NotificationFailure('NotificationService chưa được khởi tạo'));
      }
    } catch (e) {
      emit(NotificationFailure('Không thể hiển thị thông báo'));
    }
  }
}
