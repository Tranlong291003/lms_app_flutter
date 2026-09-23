import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/status_chip.dart';

/// Màn hình bảo mật tài khoản.
///
/// Chỉ "Đổi mật khẩu" là có thật. Sáu mục còn lại chưa có màn hình/API tương
/// ứng — trước đây chúng vẫn vẽ mũi tên ">" và bấm được, nhưng bấm vào chỉ
/// hiện "Chức năng đang được phát triển". Giờ chúng hiện nhãn "Sắp ra mắt" và
/// **không bấm được**, để người dùng biết trước thay vì thử rồi thất vọng.
class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  /// Mục chưa có tính năng: không có `onTap`.
  static const _comingSoon = <(IconData, String, String)>[
    (
      Icons.security,
      'Xác thực hai yếu tố',
      'Bảo mật tài khoản với xác thực 2 lớp',
    ),
    (
      Icons.help_outline,
      'Câu hỏi bảo mật',
      'Thiết lập câu hỏi bảo mật để khôi phục tài khoản',
    ),
    (
      Icons.devices_other,
      'Thiết bị đã đăng nhập',
      'Xem và quản lý các thiết bị đã đăng nhập',
    ),
    (
      Icons.history,
      'Lịch sử đăng nhập',
      'Xem lịch sử đăng nhập gần đây',
    ),
    (
      Icons.visibility_outlined,
      'Quyền truy cập dữ liệu',
      'Kiểm soát quyền truy cập vào dữ liệu của bạn',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Bảo mật', showBack: true),
      body: ListView(
        // Cộng thêm vùng an toàn đáy: mục cuối từng nằm dưới home indicator.
        padding: listPaddingWithBottomInset(context),
        children: [
          const _SectionTitle('Bảo mật tài khoản'),

          // Mục duy nhất đã hoạt động.
          _SecurityOption(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Cập nhật mật khẩu của bạn',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.changePassword),
          ),

          for (final (icon, title, subtitle) in _comingSoon)
            _SecurityOption(icon: icon, title: title, subtitle: subtitle),

          const SizedBox(height: AppSpacing.xxl),
          const _SectionTitle('Quyền riêng tư'),

          // Xoá tài khoản là hành động nguy hiểm chưa có API — hiện rõ là
          // chưa hỗ trợ thay vì để bấm được rồi báo "đang phát triển".
          const _SecurityOption(
            icon: Icons.delete_outline,
            title: 'Xoá tài khoản',
            subtitle: 'Xoá vĩnh viễn tài khoản và dữ liệu của bạn',
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.md,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Một mục trong màn bảo mật.
///
/// `onTap == null` nghĩa là tính năng chưa có: thẻ không có mũi tên, không có
/// hiệu ứng bấm, và hiện nhãn "Sắp ra mắt".
class _SecurityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SecurityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isAvailable = onTap != null;

    final accent = isDestructive ? scheme.error : scheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderLg,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  // Mục chưa dùng được thì làm mờ icon để khác biệt thị giác.
                  color: accent.withValues(alpha: isAvailable ? 0.12 : 0.07),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isAvailable
                      ? accent
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isAvailable && !isDestructive
                            ? null
                            : (isDestructive
                                  ? scheme.error
                                  : scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDestructive
                            ? scheme.error.withValues(alpha: 0.85)
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isAvailable)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                )
              else
                const StatusChip(
                  label: 'Sắp ra mắt',
                  tone: StatusTone.neutral,
                  showDot: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
