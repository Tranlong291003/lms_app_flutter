import 'package:flutter/material.dart';
import 'package:lms/apps/utils/FeInDevMessaage.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Chính sách bảo mật', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thông tin về chính sách
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? colorScheme.surfaceContainerHighest.withOpacity(0.3)
                      : colorScheme.surfaceContainerHighest.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
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
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Chính sách thông tin cá nhân',
              );
            },
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.cookie_outlined,
            title: 'Cookie và dữ liệu',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Chính sách cookie và dữ liệu',
              );
            },
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.security_outlined,
            title: 'Bảo mật dữ liệu',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Chính sách bảo mật dữ liệu',
              );
            },
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.share_outlined,
            title: 'Chia sẻ thông tin',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Chính sách chia sẻ thông tin',
              );
            },
          ),

          _buildPrivacyItem(
            context: context,
            icon: Icons.child_care_outlined,
            title: 'Bảo vệ trẻ em',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Chính sách bảo vệ trẻ em',
              );
            },
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
                          onPressed: () {
                            showFeatureInDevelopmentMessage(
                              context,
                              'Gửi phản hồi',
                            );
                          },
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
                          onPressed: () {
                            showFeatureInDevelopmentMessage(
                              context,
                              'Liên hệ hỗ trợ',
                            );
                          },
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
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
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

  Widget _buildPrivacyItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

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
                  color: theme.colorScheme.primary.withOpacity(0.1),
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
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
