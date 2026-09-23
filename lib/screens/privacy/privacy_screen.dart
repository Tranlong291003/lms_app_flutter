import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _supportEmail = 'tranlong291003@example.com';

  /// Mở ứng dụng email của hệ thống. Nếu không có ứng dụng nào xử lý được thì
  /// báo cho người dùng biết thay vì im lặng.
  Future<void> _launchEmail(
    BuildContext context, {
    String subject = 'Phản hồi về chính sách bảo mật',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent(subject)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Không mở được ứng dụng email.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Không mở được ứng dụng email.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Chính sách bảo mật', showBack: true),
      body: ListView(
        // Cong them vung an toan day: muc cuoi tung nam duoi home indicator.
        padding: listPaddingWithBottomInset(context),
        children: [
          // Thông tin về chính sách
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                // Viền lấy từ theme: `Colors.grey.shade300` ở dark mode là
                // đường kẻ sáng chói cắt ngang nền tối.
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Chính sách bảo mật này giải thích cách chúng tôi thu thập, sử dụng và bảo vệ thông tin của bạn.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Các chính sách', theme),

          // Danh sách các chính sách
          _buildPrivacyItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.cookie_outlined,
            title: 'Cookie và dữ liệu',
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.security_outlined,
            title: 'Bảo mật dữ liệu',
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.share_outlined,
            title: 'Chia sẻ thông tin',
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.child_care_outlined,
            title: 'Bảo vệ trẻ em',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Yêu cầu và liên hệ', theme),

          // Các tùy chọn liên hệ
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn có thắc mắc về chính sách bảo mật?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          // Mở ứng dụng email thay vì báo "đang phát triển".
                          onPressed: () => _launchEmail(context),
                          icon: const Icon(Icons.feedback_outlined),
                          label: const Text('Gửi phản hồi'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchEmail(
                            context,
                            subject: 'Cần hỗ trợ về chính sách bảo mật',
                          ),
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Liên hệ hỗ trợ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Phiên bản và cập nhật
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Phiên bản chính sách: 1.0.0\nCập nhật lần cuối: 01/06/2024',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
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

  /// Mục chính sách: hiển thị thông tin, KHÔNG phải liên kết.
  ///
  /// Trước đây mỗi mục có mũi tên ">" và bấm vào chỉ hiện "Chức năng đang được
  /// phát triển" — trong khi nội dung chính sách đã có sẵn ở màn này. Giờ các
  /// mục chỉ là tiêu đề nhóm, không có affordance bấm.
  Widget _buildPrivacyItem({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
