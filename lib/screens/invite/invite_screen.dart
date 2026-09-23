import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(showBack: true, title: 'Mời bạn bè'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(theme),
          const SizedBox(height: 32),
          _buildSectionTitle('Chia sẻ với bạn bè', theme),
          _buildShareOption(
            icon: Icons.share,
            title: 'Chia sẻ qua tin nhắn',
            subtitle: 'Gửi link qua SMS, Messenger, Zalo...',
            onTap: () => _showUnavailable(context, 'Chia sẻ qua tin nhắn'),
            theme: theme,
          ),
          _buildShareOption(
            icon: Icons.copy,
            title: 'Sao chép link',
            subtitle: 'Copy link và chia sẻ với bạn bè',
            onTap: () => _showUnavailable(context, 'Sao chép link'),
            theme: theme,
          ),
          _buildShareOption(
            icon: Icons.qr_code,
            title: 'Mã QR',
            subtitle: 'Quét mã QR để tham gia',
            onTap: () => _showUnavailable(context, 'Mã QR'),
            theme: theme,
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Bạn bè đã tham gia', theme),
          _buildFriendList(theme),
        ],
      ),
    );
  }

  void _showUnavailable(BuildContext context, String feature) {
    CustomSnackBar.showInfo(
      context: context,
      message: '$feature chưa được hỗ trợ trên phiên bản này.',
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Dùng `colorScheme.primary` + bản đậm hơn của chính nó. Trước đây
          // dùng `theme.primaryColor` (màu thương hiệu CỐ ĐỊNH) trong khi chữ
          // là `colorScheme.onPrimary` — ở dark mode `onPrimary` là màu navy
          // đậm nên chữ trên nền xanh chỉ đạt ~2:1, gần như không đọc được.
          colors: [
            theme.colorScheme.primary,
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.25),
              theme.colorScheme.primary,
            ),
          ],
        ),
        borderRadius: AppRadius.borderLg,
      ),
      child: Column(
        children: [
          Icon(
            Icons.card_giftcard,
            size: 48,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: 16),
          Text(
            'Mời bạn bè tham gia',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhận ưu đãi đặc biệt khi mời bạn bè tham gia',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: AppRadius.borderPill,
            ),
            child: Text(
              'Nhận 50% giá trị khóa học',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
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
          color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 24, color: theme.primaryColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  /// Danh sách bạn bè đã tham gia.
  ///
  /// Trước đây hàm này tự SINH ra 3 "Bạn bè 1/2/3" kèm "Đã tham gia N ngày
  /// trước" và "10%/20%/30%" — dữ liệu bịa hoàn toàn, không lấy từ đâu cả.
  /// Người dùng bị dẫn tới tin rằng đã mời được bạn và đang được hưởng ưu đãi.
  /// App chưa có API cho tính năng mời bạn, nên hiển thị trạng thái rỗng thật.
  Widget _buildFriendList(ThemeData theme) {
    return const EmptyStateWidget(
      icon: Icons.group_outlined,
      title: 'Chưa có bạn bè nào tham gia',
      message:
          'Khi bạn bè dùng link của bạn để đăng ký, họ sẽ xuất hiện ở đây.',
    );
  }
}
