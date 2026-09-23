import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Thanh toán', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Phương thức thanh toán', theme),

          // Danh sách phương thức thanh toán
          _buildPaymentMethod(
            context: context,
            title: 'Thẻ tín dụng/Ghi nợ',
            icon: Icons.credit_card,
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildPaymentMethod(
            context: context,
            title: 'Ví điện tử',
            icon: Icons.account_balance_wallet,
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          _buildPaymentMethod(
            context: context,
            title: 'Chuyển khoản ngân hàng',
            icon: Icons.account_balance,
            onTap: () {
              CustomSnackBar.showInfo(
                context: context,
                message: 'Chức năng đang được phát triển',
              );
            },
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Lịch sử giao dịch', theme),

          // Lịch sử giao dịch.
          //
          // Khối này trước đây vẽ CỨNG "Chưa có giao dịch nào" mà không gọi API
          // nào cả — nên người dùng ĐÃ có giao dịch vẫn thấy thông báo trống,
          // tức là thông tin sai. App chưa có API thanh toán, nên nói rõ tính
          // năng chưa có thay vì khẳng định sai về dữ liệu.
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Lịch sử giao dịch chưa được hỗ trợ',
            message:
                'Tính năng thanh toán chưa hoàn thiện nên chưa có lịch sử giao dịch.',
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Mã giảm giá', theme),

          // Form nhập mã giảm giá
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nhập mã giảm giá', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Nhập mã giảm giá',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          CustomSnackBar.showInfo(
                            context: context,
                            message: 'Chức năng đang được phát triển',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Áp dụng'),
                      ),
                    ],
                  ),
                ],
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

  Widget _buildPaymentMethod({
    required BuildContext context,
    required String title,
    required IconData icon,
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
