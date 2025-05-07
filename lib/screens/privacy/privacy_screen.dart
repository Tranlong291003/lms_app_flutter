import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(title: 'Chính sách bảo mật'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Thông tin cá nhân', theme),
          _buildPrivacyCard(
            context,
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            content:
                'Chúng tôi thu thập thông tin cá nhân của bạn khi bạn đăng ký tài khoản, sử dụng dịch vụ hoặc liên hệ với chúng tôi.',
            theme: theme,
          ),
          _buildPrivacyCard(
            context,
            icon: Icons.devices_other,
            title: 'Thông tin thiết bị',
            content:
                'Chúng tôi thu thập thông tin về thiết bị của bạn để cải thiện trải nghiệm người dùng và bảo mật.',
            theme: theme,
          ),
          _buildSectionTitle('Sử dụng thông tin', theme),
          _buildPrivacyCard(
            context,
            icon: Icons.settings,
            title: 'Cung cấp dịch vụ',
            content:
                'Thông tin của bạn được sử dụng để cung cấp, duy trì và cải thiện dịch vụ của chúng tôi.',
            theme: theme,
          ),
          _buildPrivacyCard(
            context,
            icon: Icons.security,
            title: 'Bảo mật',
            content:
                'Chúng tôi sử dụng thông tin để bảo vệ tài khoản của bạn và ngăn chặn các hoạt động trái phép.',
            theme: theme,
          ),
          _buildPrivacyCard(
            context,
            icon: Icons.share,
            title: 'Chia sẻ thông tin',
            content:
                'Chúng tôi không chia sẻ thông tin cá nhân của bạn với bên thứ ba trừ khi có sự đồng ý của bạn hoặc theo quy định pháp luật.',
            theme: theme,
          ),
          _buildPrivacyCard(
            context,
            icon: Icons.verified_user,
            title: 'Quyền của bạn',
            content:
                'Bạn có quyền truy cập, chỉnh sửa hoặc xóa thông tin cá nhân của mình bất cứ lúc nào.',
            theme: theme,
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
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: theme.primaryColor, size: 28),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(content, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
