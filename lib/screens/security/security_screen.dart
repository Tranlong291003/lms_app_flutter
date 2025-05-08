import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/config/app_router.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Bảo mật'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Tài khoản', theme),
          _buildSecurityItem(
            context: context,
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () => Navigator.pushNamed(context, AppRouter.changePassword),
          ),
          _buildSecurityItem(
            context: context,
            icon: Icons.phone_android_outlined,
            title: 'Xác thực 2 yếu tố',
            subtitle: 'Bảo vệ tài khoản của bạn bằng xác thực 2 yếu tố',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement 2FA
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Đăng nhập', theme),
          _buildSecurityItem(
            context: context,
            icon: Icons.devices_outlined,
            title: 'Thiết bị đã đăng nhập',
            subtitle: 'Quản lý các thiết bị đã đăng nhập vào tài khoản của bạn',
            onTap: () {
              // TODO: Implement device management
            },
          ),
          _buildSecurityItem(
            context: context,
            icon: Icons.history_outlined,
            title: 'Lịch sử đăng nhập',
            subtitle: 'Xem lịch sử đăng nhập của bạn',
            onTap: () {
              // TODO: Implement login history
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSecurityItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: theme.primaryColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
        onTap: onTap,
      ),
    );
  }
}
