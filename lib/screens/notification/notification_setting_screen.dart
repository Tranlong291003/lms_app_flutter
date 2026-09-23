import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/services/notification_preferences.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends State<NotificationSettingScreen> {
  bool _course = NotificationPreferences.defaultCourse;
  bool _message = NotificationPreferences.defaultMessage;
  bool _promotion = NotificationPreferences.defaultPromotion;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final course = await NotificationPreferences.getCourse();
    final message = await NotificationPreferences.getMessage();
    final promotion = await NotificationPreferences.getPromotion();
    if (!mounted) return;
    setState(() {
      _course = course;
      _message = message;
      _promotion = promotion;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'Thông báo', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Cài đặt thông báo', theme),
          if (!_loaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            _buildNotificationOption(
              context: context,
              title: 'Thông báo khóa học',
              subtitle: 'Nhận thông báo về các khóa học mới, cập nhật bài học',
              isEnabled: _course,
              onChanged: (value) {
                setState(() => _course = value);
                NotificationPreferences.setCourse(value);
              },
            ),
            _buildNotificationOption(
              context: context,
              title: 'Thông báo tin nhắn',
              subtitle: 'Nhận thông báo khi có tin nhắn mới từ giảng viên',
              isEnabled: _message,
              onChanged: (value) {
                setState(() => _message = value);
                NotificationPreferences.setMessage(value);
              },
            ),
            _buildNotificationOption(
              context: context,
              title: 'Thông báo khuyến mãi',
              subtitle: 'Nhận thông báo về các chương trình khuyến mãi, ưu đãi',
              isEnabled: _promotion,
              onChanged: (value) {
                setState(() => _promotion = value);
                NotificationPreferences.setPromotion(value);
              },
            ),
          ],

          const SizedBox(height: 24),
          _buildSectionTitle('Lịch sử thông báo', theme),

          // Trước đây chỗ này vẽ một khối "Chưa có thông báo nào" CỨNG kèm nút
          // "Làm mới" chỉ báo "đang phát triển" — dù app đã có màn hình thông
          // báo thật (NotificationsScreen + NotificationCubit) và API đọc được
          // dữ liệu. Người dùng bị dẫn tới kết luận sai là không có thông báo.
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xem tất cả thông báo',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Danh sách thông báo của bạn nằm ở màn hình riêng.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.notifications),
                    icon: const Icon(Icons.list_alt_rounded, size: 20),
                    label: const Text('Mở danh sách thông báo'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

