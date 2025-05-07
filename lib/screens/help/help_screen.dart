import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'Trung tâm trợ giúp'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Câu hỏi thường gặp', theme),
          _buildHelpCard(
            icon: Icons.help_outline,
            title: 'Làm thế nào để đăng ký tài khoản?',
            content:
                'Bạn có thể đăng ký tài khoản bằng email hoặc số điện thoại.',
            theme: theme,
          ),
          _buildHelpCard(
            icon: Icons.lock_outline,
            title: 'Tôi quên mật khẩu, phải làm sao?',
            content:
                'Sử dụng chức năng "Quên mật khẩu" trên màn hình đăng nhập.',
            theme: theme,
          ),
          _buildSectionTitle('Hướng dẫn sử dụng', theme),
          _buildHelpCard(
            icon: Icons.play_circle_outline,
            title: 'Bắt đầu với khoá học',
            content: 'Chọn khoá học bạn muốn và nhấn "Đăng ký" để bắt đầu.',
            theme: theme,
          ),
          _buildSectionTitle('Liên hệ hỗ trợ', theme),
          _buildHelpCard(
            icon: Icons.email_outlined,
            title: 'Email hỗ trợ',
            content: 'support@lms.com',
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
          color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHelpCard({
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 24),
        ),
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
