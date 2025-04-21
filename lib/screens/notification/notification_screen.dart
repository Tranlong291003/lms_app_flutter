import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> notifications = {
      'Hôm nay': [
        {
          'icon': Icons.payment,
          'color': Colors.blue,
          'title': 'Thanh toán thành công!',
          'message': 'Bạn đã thanh toán khóa học thành công.',
        },
        {
          'icon': Icons.card_giftcard,
          'color': Colors.amber,
          'title': 'Ưu đãi đặc biệt hôm nay',
          'message': 'Bạn nhận được khuyến mãi đặc biệt!',
        },
      ],
      'Hôm qua': [
        {
          'icon': Icons.new_releases,
          'color': Colors.red,
          'title': 'Khoá học mới được thêm!',
          'message': 'Khoá học thiết kế 3D đã sẵn sàng.',
        },
        {
          'icon': Icons.credit_card,
          'color': Colors.indigo,
          'title': 'Đã kết nối thẻ ngân hàng',
          'message': 'Thẻ của bạn đã được liên kết.',
        },
      ],
      '22/12/2024': [
        {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'title': 'Tạo tài khoản thành công',
          'message': 'Tài khoản của bạn đã được tạo.',
        },
      ],
    };

    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: 'Thông báo', showMenu: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            notifications.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
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
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: item['color'].withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'], color: item['color']),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['message'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
      ),
    );
  }
}
