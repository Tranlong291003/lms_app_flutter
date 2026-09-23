import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _supportEmail = 'tranlong291003@example.com';
  static const _supportPhone = '0889112490';

  /// Mở ứng dụng ngoài (mail/điện thoại). Nếu hệ thống không có ứng dụng nào
  /// xử lý được thì báo cho người dùng biết thay vì im lặng.
  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Không mở được ứng dụng cho liên kết này.',
        );
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context: context,
          message: 'Không mở được ứng dụng cho liên kết này.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'Trung tâm trợ giúp', showBack: true),
      body: ListView(
        // Cong them vung an toan day: muc cuoi tung nam duoi home indicator.
        padding: listPaddingWithBottomInset(context),
        children: [
          // Tìm kiếm câu hỏi.
          //
          // Trước đây `onChanged` hiện một SnackBar cho MỖI ký tự gõ vào: gõ
          // "khóa học" là 7 thông báo xếp chồng, che gần hết màn hình. Chỉ báo
          // một lần khi người dùng thực sự gõ, và không lặp lại liên tục.
          TextField(
            onSubmitted: (value) {
              if (value.trim().isEmpty) return;
              CustomSnackBar.showInfo(
                context: context,
                message: 'Tìm kiếm câu hỏi đang được phát triển',
              );
            },
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm câu hỏi',
              prefixIcon: Icon(Icons.search),
              // Viền và đệm lấy từ `inputDecorationTheme` — trước đây tự khai
              // báo lại bằng `Colors.grey.shade300/700` nên lệch tông với mọi
              // ô nhập khác trong app.
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Câu hỏi thường gặp', theme),

          // Danh sách câu hỏi thường gặp
          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để đăng ký khóa học?',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để thanh toán khóa học?',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Tôi có thể học trên thiết bị nào?',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Làm thế nào để nhận chứng chỉ?',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildFaqItem(
            context: context,
            question: 'Chính sách hoàn tiền như thế nào?',
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
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
                  // Email và điện thoại là hành động THẬT — trước đây cả hai
                  // đều chỉ hiện "Chức năng đang được phát triển" dù địa chỉ và
                  // số đã hiển thị ngay bên dưới. Giờ mở ứng dụng tương ứng.
                  _buildContactMethod(
                    context: context,
                    icon: Icons.chat_outlined,
                    title: 'Chat trực tuyến',
                    subtitle: 'Chat với đội ngũ hỗ trợ',
                    onTap: () {
                      CustomSnackBar.showInfo(
                        context: context,
                        message: 'Chức năng đang được phát triển',
                      );
                    },
                  ),

                  const Divider(height: 24),

                  _buildContactMethod(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: _supportEmail,
                    onTap: () => _launch(context, Uri(scheme: 'mailto', path: _supportEmail)),
                  ),

                  const Divider(height: 24),

                  _buildContactMethod(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Điện thoại',
                    subtitle: _supportPhone,
                    onTap: () => _launch(context, Uri(scheme: 'tel', path: _supportPhone)),
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
                CustomSnackBar.showInfo(
                  context: context,
                  message: 'Chức năng đang được phát triển',
                );
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
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
