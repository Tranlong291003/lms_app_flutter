import 'package:flutter/material.dart';

class Role {
  final String id;
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });

  static const List<Role> availableRoles = [
    Role(
      id: 'admin',
      name: 'Admin',
      description: 'Quản trị viên hệ thống',
      color: Colors.purple,
      icon: Icons.admin_panel_settings,
    ),
    Role(
      id: 'mentor',
      name: 'Mentor',
      description: 'Giảng viên, người hướng dẫn',
      color: Colors.blue,
      icon: Icons.school,
    ),
    Role(
      id: 'user',
      name: 'Người dùng',
      description: 'Người dùng thông thường',
      color: Colors.teal,
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
