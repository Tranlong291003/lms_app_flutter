import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'Bảo mật', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Bảo mật tài khoản', theme),

          // Đổi mật khẩu
          _buildSecurityOption(
            context: context,
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () => Navigator.pushNamed(context, AppRouter.changePassword),
          ),

          // Xác thực hai yếu tố
          _buildSecurityOption(
            context: context,
            icon: Icons.security,
            title: 'Xác thực hai yếu tố',
            subtitle: 'Bảo mật tài khoản với xác thực 2 lớp',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
          ),

          // Câu hỏi bảo mật
          _buildSecurityOption(
            context: context,
            icon: Icons.help_outline,
            title: 'Câu hỏi bảo mật',
            subtitle: 'Thiết lập câu hỏi bảo mật để khôi phục tài khoản',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Quản lý phiên đăng nhập', theme),

          // Thiết bị đã đăng nhập
          _buildSecurityOption(
            context: context,
            icon: Icons.devices_other,
            title: 'Thiết bị đã đăng nhập',
            subtitle: 'Xem và quản lý các thiết bị đã đăng nhập',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
          ),

          // Lịch sử đăng nhập
          _buildSecurityOption(
            context: context,
            icon: Icons.history,
            title: 'Lịch sử đăng nhập',
            subtitle: 'Xem lịch sử đăng nhập gần đây',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Quyền riêng tư', theme),

          // Quyền truy cập dữ liệu
          _buildSecurityOption(
            context: context,
            icon: Icons.visibility_outlined,
            title: 'Quyền truy cập dữ liệu',
            subtitle: 'Kiểm soát quyền truy cập vào dữ liệu của bạn',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
          ),

          // Xóa tài khoản
          _buildSecurityOption(
            context: context,
            icon: Icons.delete_outline,
            title: 'Xóa tài khoản',
            subtitle: 'Xóa vĩnh viễn tài khoản và dữ liệu của bạn',
            isDestructive: true,
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triền',
              );
            },
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

  Widget _buildSecurityOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? colorScheme.error.withOpacity(0.1)
                          : colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color:
                      isDestructive ? colorScheme.error : colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? colorScheme.error : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            isDestructive
                                ? colorScheme.error.withOpacity(0.8)
                                : colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color:
                    isDestructive
                        ? colorScheme.error.withOpacity(0.5)
                        : colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
