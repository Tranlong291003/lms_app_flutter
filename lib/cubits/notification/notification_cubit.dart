import 'package:bloc/bloc.dart';
import 'package:lms/cubits/notification/notification_state.dart';
import 'package:lms/services/notification_service.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService _notificationService;

  NotificationCubit(this._notificationService) : super(NotificationInitial());

  // Hàm để hiển thị thông báo cục bộ
  Future<void> showNotification(
    String title,
    String body,
    int notificationId,
  ) async {
    try {
      emit(NotificationLoading());
      // Gọi NotificationService để hiển thị thông báo cục bộ
      await _notificationService.showNotification(title, body, notificationId);
      emit(NotificationSuccess());
    } catch (e) {
      emit(NotificationFailure('Không thể hiển thị thông báo'));
    }
  }
}
