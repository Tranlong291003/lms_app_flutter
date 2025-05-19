import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';

class AdminDashboardScreen extends StatelessWidget {
  final String userName;
  const AdminDashboardScreen({super.key, required this.userName});

  void _navigateToUserManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminUsers);
  }

  void _navigateToCourseManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminCourses);
  }

  void _navigateToCategoryManagement(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.adminCategories);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trang điều khiển',

        showMenu: true,
        menuItems: [],
        onMenuSelected: (value) {},
      ),
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
                  const _StatsGrid(),
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

            // Bottom space for better UX
            const SizedBox(height: 40),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionCard(
          icon: Icons.people,
          title: 'Quản lý người dùng',
          subtitle: 'Quản lý học viên, giảng viên và quản trị viên',
          color: Colors.indigo,
          onTap: () => _navigateToUserManagement(context),
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.school,
          title: 'Quản lý khóa học',
          subtitle: 'Phê duyệt, từ chối và quản lý tất cả khóa học',
          color: Colors.teal,
          onTap: () => _navigateToCourseManagement(context),
        ),

        const SizedBox(height: 12),

        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.category,
          title: 'Quản lý danh mục',
          subtitle: 'Thêm, sửa, xóa danh mục và bộ lọc',
          color: Colors.amber.shade700,
          onTap: () => _navigateToCategoryManagement(context),
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.payments_outlined,
          title: 'Quản lý thanh toán',
          subtitle: 'Xem và quản lý các giao dịch thanh toán',
          color: Colors.green,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.settings,
          title: 'Cài đặt hệ thống',
          subtitle: 'Cấu hình chung và tùy chỉnh giao diện người dùng',
          color: Colors.purple,
          onTap: () {},
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
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
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
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
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
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<_Stat> stats = [
      _Stat('Tổng khóa học', '125', Icons.school, Colors.indigo),
      _Stat('Tổng người dùng', '1,458', Icons.people, Colors.teal),
      _Stat('Số bài kiểm tra', '432', Icons.quiz, Colors.red),
      _Stat('Lượt đánh giá', '758', Icons.star_rate, Colors.amber),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (_, i) {
        final s = stats[i];
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? colors.surfaceContainerHighest
                      : s.color.withOpacity(0.05),
                  isDark
                      ? colors.surfaceContainerHigh
                      : s.color.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withOpacity(0.15)
                        : s.color.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(isDark ? .25 : .15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.icon, color: s.color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  s.value,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: s.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.title,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _Stat(this.title, this.value, this.icon, this.color);
}
