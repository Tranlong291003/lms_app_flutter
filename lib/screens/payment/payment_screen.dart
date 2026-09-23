import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/status_chip.dart';

/// Màn hình thanh toán.
///
/// App chưa có API thanh toán nào, nên màn này KHÔNG giả vờ là dùng được:
/// trước đây ba "phương thức thanh toán" là ba thẻ bấm được nhưng chỉ hiện
/// "Chức năng đang được phát triển", và ô nhập mã giảm giá thì **không có
/// controller** nên gõ vào xong bấm "Áp dụng" là mất sạch nội dung.
///
/// Giờ các phương thức hiển thị ở trạng thái chờ, không bấm được, để người
/// dùng không mất thời gian thử.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  static const _methods = <(String, IconData)>[
    ('Thẻ tín dụng/Ghi nợ', Icons.credit_card),
    ('Ví điện tử', Icons.account_balance_wallet),
    ('Chuyển khoản ngân hàng', Icons.account_balance),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Thanh toán', showBack: true),
      body: ListView(
        // Cộng thêm vùng an toàn đáy: mục cuối từng nằm dưới home indicator.
        padding: listPaddingWithBottomInset(context),
        children: [
          _SectionTitle('Phương thức thanh toán'),

          for (final (title, icon) in _methods)
            _PaymentMethodTile(title: title, icon: icon),

          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle('Lịch sử giao dịch'),

          // Khối này trước đây vẽ CỨNG "Chưa có giao dịch nào" mà không gọi API
          // nào cả — nên người dùng ĐÃ có giao dịch vẫn thấy thông báo trống,
          // tức là thông tin sai.
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Lịch sử giao dịch chưa được hỗ trợ',
            message:
                'Tính năng thanh toán chưa hoàn thiện nên chưa có lịch sử giao dịch.',
          ),

          const SizedBox(height: AppSpacing.xxl),
          _SectionTitle('Mã giảm giá'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Mã giảm giá sẽ khả dụng khi tính năng thanh toán hoàn thiện.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiêu đề một nhóm nội dung trong màn cài đặt.
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

/// Một phương thức thanh toán ở trạng thái *chờ hỗ trợ*.
///
/// Không dùng `InkWell`: thẻ không bấm được thì không nên có hiệu ứng bấm.
class _PaymentMethodTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PaymentMethodTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const StatusChip(label: 'Sắp ra mắt', tone: StatusTone.neutral),
          ],
        ),
      ),
    );
  }
}
