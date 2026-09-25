import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/stat_grid.dart';
import 'package:lms/apps/utils/status_chip.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/admin/app_stats_cubit.dart';
import 'package:lms/repositories/app_stats_repository.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/mentor_request/mentor_request_admin_screen.dart';
import 'package:lms/services/app_stats_service.dart';

/// Màu ngữ nghĩa của theme hiện tại.
AppColors _c(BuildContext context) => AppColors.of(context);

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('Building AdminDashboardScreen', name: 'AdminDashboard');

    final uid = context.read<AuthCubit>().state.userId;
    developer.log('Current user: $uid', name: 'AdminDashboard');

    if (uid == null || uid.isEmpty) {
      developer.log(
        'No user found, redirecting to login',
        name: 'AdminDashboard',
      );
      // Redirect to login screen if not authenticated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    return BlocProvider(
      create: (context) {
        developer.log(
          'Creating AppStatsCubit with uid: $uid',
          name: 'AdminDashboard',
        );
        return AppStatsCubit(AppStatsRepository(AppStatsService()))
          ..fetchStats(uid);
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Trang điều khiển', centerTitle: true),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- DASHBOARD STATS ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Thống kê hệ thống'),
                    const SizedBox(height: 16),
                    BlocBuilder<AppStatsCubit, AppStatsState>(
                      builder: (context, state) {
                        developer.log(
                          'Building stats with state: ${state.runtimeType}',
                          name: 'AdminDashboard',
                        );

                        if (state is AppStatsLoading) {
                          developer.log(
                            'Loading stats...',
                            name: 'AdminDashboard',
                          );
                          return const Center(child: LoadingIndicator());
                        }

                        if (state is AppStatsError) {
                          developer.log(
                            'Error loading stats: ${state.message}',
                            name: 'AdminDashboard',
                          );
                          return EmptyStateWidget(
                            icon: Icons.cloud_off_rounded,
                            title: 'Không tải được số liệu',
                            message: state.message,
                            isError: true,
                            actionLabel: 'Thử lại',
                            onAction: () {
                              context.read<AppStatsCubit>().fetchStats(uid);
                            },
                          );
                        }

                        if (state is AppStatsLoaded) {
                          final stats = state.stats;
                          developer.log(
                            'Stats loaded successfully: ${stats.toString()}',
                            name: 'AdminDashboard',
                          );
                          // Màu lấy từ bảng màu ngữ nghĩa của theme thay vì
                          // `Colors.indigo/teal/red/amber`: bốn màu Material
                          // đó không nằm trong bảng màu app và khi dùng làm màu
                          // CHỮ số liệu trên nền tối chỉ đạt ~2.1:1.
                          final c = AppColors.of(context);
                          return StatGrid(
                            stats: [
                              StatItem(
                                title: 'Tổng khoá học',
                                value: stats.totalCourses.toString(),
                                icon: Icons.school,
                                color: c.info,
                              ),
                              StatItem(
                                title: 'Tổng người dùng',
                                value: stats.totalUsers?.toString() ?? '-',
                                icon: Icons.people,
                                color: c.success,
                              ),
                              StatItem(
                                title: 'Số bài kiểm tra',
                                value: stats.totalQuizzes?.toString() ?? '-',
                                icon: Icons.quiz,
                                color: c.warning,
                              ),
                              StatItem(
                                title: 'Lượt đánh giá',
                                value: stats.totalReviews?.toString() ?? '-',
                                icon: Icons.star_rate,
                                color: c.error,
                              ),
                            ],
                          );
                        }

                        developer.log(
                          'Unknown state: ${state.runtimeType}',
                          name: 'AdminDashboard',
                        );
                        return const Center(child: LoadingIndicator());
                      },
                    ),
                  ],
                ),
              ),

              // ---------- QUICK ACTIONS ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Quản lý hệ thống'),
                    const SizedBox(height: 16),
                    const _QuickActionsList(),
                  ],
                ),
              ),

              // Chừa vùng an toàn dưới đáy (home indicator) thay vì hằng số
              // 40px cứng.
              SizedBox(
                height: MediaQuery.viewPaddingOf(context).bottom + AppSpacing.xxl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget hiển thị danh sách các thao tác nhanh
class _QuickActionsList extends StatelessWidget {
  const _QuickActionsList();

  void _navigateToUserManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminUsers);
  }

  void _navigateToCourseManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminCourses);
  }

  void _navigateToCategoryManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminCategories);
  }

  void _navigateToMentorRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MentorRequestAdminScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Màu lấy từ bảng màu ngữ nghĩa của theme — `Colors.deepPurple` và
    // `Colors.purple` trước đây thậm chí không nằm trong bảng màu app.
    final c = AppColors.of(context);
    return Column(
      children: [
        _QuickActionCard(
          icon: Icons.people,
          title: 'Quản lý người dùng',
          subtitle: 'Quản lý học viên, giảng viên và quản trị viên',
          color: c.info,
          onTap: () => _navigateToUserManagement(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _QuickActionCard(
          icon: Icons.school,
          title: 'Quản lý khoá học',
          subtitle: 'Phê duyệt, từ chối và quản lý tất cả khoá học',
          color: c.success,
          onTap: () => _navigateToCourseManagement(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _QuickActionCard(
          icon: Icons.category,
          title: 'Quản lý danh mục',
          subtitle: 'Thêm, sửa, xoá danh mục và bộ lọc',
          color: c.warning,
          onTap: () => _navigateToCategoryManagement(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _QuickActionCard(
          icon: Icons.verified_user,
          title: 'Duyệt Mentor',
          subtitle: 'Xem và duyệt các yêu cầu nâng cấp mentor',
          color: c.info,
          onTap: () => _navigateToMentorRequest(context),
        ),
        const SizedBox(height: AppSpacing.md),
        _QuickActionCard(
          icon: Icons.payments_outlined,
          title: 'Quản lý thanh toán',
          subtitle: 'Xem và quản lý các giao dịch thanh toán',
          color: c.success,
          // Chưa có màn hình/API thanh toán: không bấm được, hiện nhãn "Sắp ra
          // mắt" để người dùng biết trước. Trước đây thiếu `isComingSoon` nên
          // thẻ vẫn vẽ mũi tên "mở được" nhưng bấm không có gì xảy ra.
          isComingSoon: true,
        ),
        const SizedBox(height: AppSpacing.md),
        _QuickActionCard(
          icon: Icons.settings,
          title: 'Cài đặt hệ thống',
          subtitle: 'Cấu hình chung và tuỳ chỉnh giao diện người dùng',
          color: c.warning,
          // Chưa có màn hình tương ứng.
          isComingSoon: true,
        ),
      ],
    );
  }
}

// Card thao tác nhanh đẹp mắt
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  /// `true` khi tính năng chưa có: thẻ không bấm được và hiện nhãn "Sắp ra mắt".
  final bool isComingSoon;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceContainerHighest : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : _c(context).neutral.withValues(alpha: 0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isComingSoon)
                const StatusChip(
                  label: 'Sắp ra mắt',
                  tone: StatusTone.neutral,
                  showDot: false,
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/*------------------ Widgets con ------------------*/

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 4,
            decoration: BoxDecoration(
              color: colors.tertiary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
