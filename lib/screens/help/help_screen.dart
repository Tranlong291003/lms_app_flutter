import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  /// Câu hỏi thường gặp kèm câu trả lời.
  static const _faqs = <(String, String)>[
    (
      'Làm thế nào để đăng ký khoá học?',
      'Mở khoá học bạn muốn học, nhấn "Đăng ký khoá học miễn phí" ở thanh dưới '
          'màn hình chi tiết. Sau khi đăng ký, khoá học xuất hiện trong mục '
          '"Khoá học" ở thanh điều hướng.',
    ),
    (
      'Tôi có thể học trên thiết bị nào?',
      'Ứng dụng hiện hỗ trợ Android. Tiến độ học được lưu theo tài khoản nên '
          'bạn có thể tiếp tục ở bất kỳ thiết bị nào đăng nhập cùng tài khoản.',
    ),
    (
      'Làm thế nào để làm bài kiểm tra?',
      'Vào mục "Quiz" ở thanh điều hướng để xem danh sách bài kiểm tra của '
          'các khoá học bạn đã đăng ký. Bài kiểm tra có thể giới hạn thời gian '
          'và số lần làm.',
    ),
    (
      'Vì sao tôi không mở được bài giảng?',
      'Bài giảng được mở dần: bạn cần đăng ký khoá học và hoàn thành bài '
          'trước đó để mở khoá bài kế tiếp.',
    ),
  ];

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

          // Câu trả lời nằm ngay trong app: trước đây mỗi câu hỏi chỉ mở được
          // một thông báo "Chức năng đang được phát triển" — tức là người dùng
          // bấm vào câu hỏi mà không nhận được câu trả lời nào.
          for (final faq in _faqs)
            _FaqItem(question: faq.$1, answer: faq.$2),

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
                  // Chat trực tuyến chưa có kênh nào để nối vào — hiện nhãn
                  // "Sắp ra mắt" thay vì bấm được rồi báo "đang phát triển".
                  _buildContactMethod(
                    context: context,
                    icon: Icons.chat_outlined,
                    title: 'Chat trực tuyến',
                    subtitle: 'Sắp ra mắt',
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

          // Gửi phản hồi — mở ứng dụng email soạn sẵn tới hộp thư hỗ trợ.
          // Trước đây nút này (đóng vai trò hành động chính của màn) bấm vào chỉ
          // hiện "Chức năng đang được phát triển", trong khi địa chỉ hỗ trợ đã
          // hiển thị ngay phía trên.
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            child: ElevatedButton.icon(
              onPressed: () => _launch(
                context,
                Uri(
                  scheme: 'mailto',
                  path: _supportEmail,
                  query: 'subject=Phản hồi về ứng dụng LMS',
                ),
              ),
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Gửi phản hồi'),
              style: ElevatedButton.styleFrom(
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

  Widget _buildContactMethod({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
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
            // Mục chưa nối được kênh nào thì không vẽ mũi tên ">" (mũi tên
            // ngụ ý bấm được).
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

/// Một câu hỏi thường gặp, mở ra để xem câu trả lời.
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: AppRadius.borderLg,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.help_outline, color: scheme.primary, size: 24),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: AppSpacing.md),
                Text(widget.answer, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
