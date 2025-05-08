import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual notifications from state management
    final List<Map<String, dynamic>> notifications = [
      {
        'id': 1,
        'title': 'Khóa học mới',
        'message': 'Khóa học Flutter nâng cao đã được thêm vào danh sách',
        'type': 'course',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(minutes: 5)),
      },
      {
        'id': 2,
        'title': 'Giảm giá',
        'message': 'Giảm giá 50% cho tất cả khóa học trong tháng này',
        'type': 'promotion',
        'isRead': true,
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'id': 3,
        'title': 'Cập nhật khóa học',
        'message': 'Khóa học Node.js đã được cập nhật thêm bài học mới',
        'type': 'update',
        'isRead': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      },
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Thông báo',
        showBack: true,
        showMenu: true,
        menuItems: [
          PopupMenuItem(
            value: 'mark_all_read',
            child: Row(
              children: [
                Icon(
                  Icons.done_all_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Đánh dấu đã đọc tất cả'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'clear_all',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Xóa tất cả',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ),
          ),
        ],
        onMenuSelected: (value) {
          // TODO: Handle menu selection
        },
      ),
      body:
          notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có thông báo nào',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(notification: notification);
                },
              ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Handle notification tap
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getIconColor(
                    theme,
                    notification['type'],
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(notification['type']),
                  color: _getIconColor(theme, notification['type']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  notification['isRead']
                                      ? theme.colorScheme.onSurface.withOpacity(
                                        0.7,
                                      )
                                      : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (!notification['isRead'])
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification['createdAt']),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'course':
        return Icons.school_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'update':
        return Icons.update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(ThemeData theme, String type) {
    switch (type) {
      case 'course':
        return theme.colorScheme.primary;
      case 'promotion':
        return theme.colorScheme.tertiary;
      case 'update':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }
}
