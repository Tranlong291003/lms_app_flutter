import 'package:flutter/material.dart';

/// Sắc thái màu của một vai trò, ánh xạ sang bảng màu của theme.
///
/// Model **không** giữ `Color` trực tiếp: màu Material cố định
/// (`Colors.purple/blue/teal`) không đổi theo chế độ sáng/tối, nên trên nền tối
/// chúng chỉ đạt ~3.9:1 — dưới ngưỡng 4.5:1. Dùng [Role.colorOf] để lấy màu
/// đúng cho theme hiện tại.
enum RoleTone { admin, mentor, user }

class Role {
  final String id;
  final String name;
  final String description;
  final RoleTone tone;
  final IconData icon;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.tone,
    required this.icon,
  });

  /// Màu đại diện của vai trò theo theme hiện tại.
  Color colorOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      RoleTone.admin => scheme.tertiary,
      RoleTone.mentor => scheme.primary,
      RoleTone.user => scheme.secondary,
    };
  }

  static const List<Role> availableRoles = [
    Role(
      id: 'admin',
      name: 'Admin',
      description: 'Quản trị viên hệ thống',
      tone: RoleTone.admin,
      icon: Icons.admin_panel_settings,
    ),
    Role(
      id: 'mentor',
      name: 'Mentor',
      description: 'Giảng viên, người hướng dẫn',
      tone: RoleTone.mentor,
      icon: Icons.school,
    ),
    Role(
      id: 'user',
      name: 'Người dùng',
      description: 'Người dùng thông thường',
      tone: RoleTone.user,
      icon: Icons.person,
    ),
  ];

  static Role getRoleById(String id) {
    return availableRoles.firstWhere(
      (role) => role.id.toLowerCase() == id.toLowerCase(),
      orElse: () => availableRoles.last,
    );
  }
}
