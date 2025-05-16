import 'package:flutter/material.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tìm kiếm
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor:
                  isDark
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16),

          // Danh sách người dùng
          ...List.generate(
            10,
            (index) => _buildUserCard(
              context,
              name: 'Nguyễn Văn ${String.fromCharCode(65 + index)}',
              email: 'user${index + 1}@example.com',
              role:
                  index % 3 == 0
                      ? 'Admin'
                      : (index % 3 == 1 ? 'Mentor' : 'Học viên'),
              isActive: index % 4 != 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context, {
    required String name,
    required String email,
    required String role,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor:
              isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    role == 'Admin'
                        ? Colors.purple.withOpacity(0.1)
                        : (role == 'Mentor'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      role == 'Admin'
                          ? Colors.purple
                          : (role == 'Mentor' ? Colors.blue : Colors.green),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                // TODO: Xử lý chỉnh sửa người dùng
              },
              icon: const Icon(Icons.edit),
              color: colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                // TODO: Xử lý khóa/mở khóa người dùng
              },
              icon: Icon(isActive ? Icons.lock : Icons.lock_open),
              color: isActive ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
