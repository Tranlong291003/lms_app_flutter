import 'package:flutter/material.dart';
import 'package:lms/apps/utils/FeInDevMessaage.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Trung tâm trợ giúp', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tìm kiếm câu hỏi
          TextField(
            onChanged: (value) {
              if (value.isNotEmpty) {
                showFeatureInDevelopmentMessage(context, 'Tìm kiếm câu hỏi');
              }
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm câu hỏi',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Câu hỏi thường gặp', theme),

          // Danh sách câu hỏi thường gặp
          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để đăng ký khóa học?',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Hướng dẫn đăng ký khóa học',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để thanh toán khóa học?',
            onTap: () {
              showFeatureInDevelopmentMessage(context, 'Hướng dẫn thanh toán');
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Tôi có thể học trên thiết bị nào?',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Thông tin thiết bị hỗ trợ',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để nhận chứng chỉ?',
            onTap: () {
              showFeatureInDevelopmentMessage(
                context,
                'Hướng dẫn nhận chứng chỉ',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Chính sách hoàn tiền như thế nào?',
            onTap: () {
              showFeatureInDevelopmentMessage(context, 'Chính sách hoàn tiền');
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Liên hệ hỗ trợ', theme),

          // Các phương thức liên hệ
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
                    'Bạn cần thêm trợ giúp?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactMethod(
                    context: context,
                    icon: Icons.chat_outlined,
                    title: 'Chat trực tuyến',
                    subtitle: 'Chat với đội ngũ hỗ trợ',
                    onTap: () {
                      showFeatureInDevelopmentMessage(
                        context,
                        'Chat trực tuyến',
                      );
                    },
                  ),

                  const Divider(height: 24),

                  _buildContactMethod(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: 'tranlong291003@example.com',
                    onTap: () {
                      showFeatureInDevelopmentMessage(
                        context,
                        'Gửi email hỗ trợ',
                      );
                    },
                  ),

                  const Divider(height: 24),

                  _buildContactMethod(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Điện thoại',
                    subtitle: '0889112490',
                    onTap: () {
                      showFeatureInDevelopmentMessage(
                        context,
                        'Gọi điện hỗ trợ',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Gửi phản hồi
          Container(
            margin: const EdgeInsets.only(top: 12),
            child: ElevatedButton.icon(
              onPressed: () {
                showFeatureInDevelopmentMessage(context, 'Gửi phản hồi');
              },
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Gửi phản hồi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

  Widget _buildFaqItem({
    required BuildContext context,
    required String question,
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
              Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
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

  Widget _buildContactMethod({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
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
    );
  }
}
