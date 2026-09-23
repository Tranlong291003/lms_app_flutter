import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/custom_dialog.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/cubits/notifications/notification_state.dart';
import 'package:lms/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  Future<void> _reload() =>
      context.read<NotificationCubit>().loadNotifications();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Dùng `CustomAppBar` cho khớp các màn hình khác: trước đây màn này dùng
      // `AppBar` mặc định nên khác chiều cao, viền dưới và kiểu tiêu đề.
      appBar: const CustomAppBar(title: 'Thông báo', showBack: true),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial || state is NotificationLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is NotificationError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_rounded,
              title: 'Không tải được thông báo',
              message: state.message,
              isError: true,
              actionLabel: 'Thử lại',
              onAction: _reload,
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              // Dùng `EmptyStateWidget` trong `ListView` để vẫn kéo-để-tải-lại
              // được. Trước đây tự dựng khối rỗng với chiều cao
              // `MediaQuery.size.height - 200` — một hằng số ma thuật, vừa
              // thừa chỗ vừa thiếu chỗ tuỳ màn hình.
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: const EmptyStateWidget(
                        icon: Icons.notifications_none_rounded,
                        title: 'Chưa có thông báo nào',
                        message:
                            'Tin tức mới về khoá học và bài kiểm tra sẽ xuất hiện ở đây.',
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: listPaddingWithBottomInset(context),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onMarkAsRead: () {
                      context.read<NotificationCubit>().markAsRead(
                        notification.notiId,
                      );
                    },
                    onDelete: () => _confirmDelete(notification),
                  );
                },
              ),
            );
          }

          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  Future<void> _confirmDelete(NotificationModel notification) async {
    final cubit = context.read<NotificationCubit>();
    await context.showCustomDialog(

      icon: Icons.delete_outline_rounded,
      title: 'Xoá thông báo',
      content: 'Thông báo đã xoá sẽ không thể khôi phục. Bạn chắc chắn chứ?',
      cancelText: 'Huỷ',
      confirmText: 'Xoá',
      // `colorScheme.error` thay vì `Colors.red` cố định.
      confirmColor: Theme.of(context).colorScheme.error,
      onConfirm: () => cubit.deleteNotification(notification.notiId),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  static const Map<String, IconData> iconMap = {
    'person': Icons.person,
    'home': Icons.home,
    'notifications': Icons.notifications,
    'message': Icons.message,
    'star': Icons.star,
    'school': Icons.school,
    'event': Icons.event,
    'assignment': Icons.assignment,
    'check': Icons.check,
    'error': Icons.error,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: isUnread ? onMarkAsRead : null,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chấm báo chưa đọc đặt TRƯỚC nội dung để không chen vào hàng
              // nút bên phải (trước đây nó nằm giữa tiêu đề và nút xoá, làm
              // hàng đó chật và dễ tràn).
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isUnread ? scheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.borderMd,
                ),
                child: Icon(
                  iconMap[notification.icon] ?? Icons.notifications,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isUnread ? FontWeight.bold : FontWeight.w500,
                        color: isUnread ? scheme.onSurface : scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(notification.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      notification.content,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                tooltip: 'Xoá thông báo',
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
