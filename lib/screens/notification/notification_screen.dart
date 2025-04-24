import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<NotificationItemModel>> notifications = {
      'Hôm nay': [
        NotificationItemModel(
          type: 'payment',
          title: 'Thanh toán thành công!',
          message: 'Bạn đã thanh toán khóa học thành công.',
          time: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        NotificationItemModel(
          type: 'promotion',
          title: 'Ưu đãi đặc biệt hôm nay',
          message: 'Bạn nhận được khuyến mãi đặc biệt!',
          time: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      'Hôm qua': [
        NotificationItemModel(
          type: 'new_course',
          title: 'Khoá học mới được thêm!',
          message: 'Khoá học thiết kế 3D đã sẵn sàng.',
          time: DateTime.now().subtract(const Duration(hours: 20)),
        ),
        NotificationItemModel(
          type: 'bank',
          title: 'Đã kết nối thẻ ngân hàng',
          message: 'Thẻ của bạn đã được liên kết.',
          time: DateTime.now().subtract(const Duration(hours: 30)),
        ),
      ],
      '22/12/2024': [
        NotificationItemModel(
          type: 'account',
          title: 'Tạo tài khoản thành công',
          message: 'Tài khoản của bạn đã được tạo.',
          time: DateTime(2024, 12, 22, 8, 0),
        ),
      ],
    };

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: 'Thông báo', showMenu: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children:
            notifications.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...entry.value.map((item) => NotificationTile(item: item)),
                  const SizedBox(height: 28),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class NotificationItemModel {
  final String type;
  final String title;
  final String message;
  final DateTime time;

  NotificationItemModel({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
  });

  IconData get icon =>
      {
        'payment': Icons.payment,
        'promotion': Icons.card_giftcard,
        'new_course': Icons.school,
        'bank': Icons.credit_card,
        'account': Icons.check_circle,
      }[type] ??
      Icons.notifications;

  Color get color =>
      {
        'payment': Colors.blue,
        'promotion': Colors.orange,
        'new_course': Colors.redAccent,
        'bank': Colors.indigo,
        'account': Colors.green,
      }[type] ??
      Colors.grey;

  String getFormattedTime() {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays == 1) return 'Hôm qua ${DateFormat('HH:mm').format(time)}';
    return DateFormat('dd/MM/yyyy HH:mm').format(time);
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationItemModel item;

  const NotificationTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  item.color.withOpacity(0.2),
                  item.color.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(item.icon, color: item.color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.getFormattedTime(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
