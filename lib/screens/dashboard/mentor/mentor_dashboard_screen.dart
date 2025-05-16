import 'package:flutter/material.dart';
import 'package:lms/apps/utils/customAppBar.dart';

import 'course_management_screen.dart';

class MentorDashboardScreen extends StatelessWidget {
  final String userName;
  const MentorDashboardScreen({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: 'Trang chủ'),
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
                  _SectionTitle('Thống kê tổng quan'),
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
                  _SectionTitle('Thao tác nhanh'),
                  const SizedBox(height: 16),
                  _QuickActionsList(
                    onCourseManagement:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CourseManagementScreen(),
                          ),
                        ),
                  ),
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
  final VoidCallback onCourseManagement;

  const _QuickActionsList({required this.onCourseManagement});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _QuickActionCard(
          icon: Icons.menu_book,
          title: 'Quản lý khóa học',
          subtitle: 'Thêm, sửa, xóa khóa học và bài giảng',
          color: Colors.blue,
          onTap: onCourseManagement,
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.people,
          title: 'Quản lý học viên',
          subtitle: 'Xem danh sách và tiến độ học viên',
          color: Colors.orange,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _QuickActionCard(
          icon: Icons.assessment,
          title: 'Báo cáo và phân tích',
          subtitle: 'Thống kê và đánh giá khóa học',
          color: Colors.green,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
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
      _Stat('Khóa học đang dạy', '5', Icons.school, Colors.indigo),
      _Stat('Học viên', '156', Icons.people, Colors.teal),
      _Stat('Bài giảng', '32', Icons.menu_book, Colors.amber.shade700),
      _Stat('Đánh giá TB', '4.8', Icons.star, Colors.purple),
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
