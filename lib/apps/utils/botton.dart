import 'package:flutter/material.dart';
import 'package:lms/blocs/theme/theme_state.dart';

// Hàm tạo ElevatedButton với text tùy chỉnh và hành động onPressed tùy chỉnh
ElevatedButton botton({
  required ThemeState themeState, // Thêm đối số ThemeState
  required String text, // Thêm đối số text
  required VoidCallback onPressed, // Thêm đối số onPressed tùy chỉnh
}) {
  return ElevatedButton(
    onPressed: onPressed, // Sử dụng hàm onPressed truyền vào
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
    ),
    child: Text(text), // Text được truyền vào
  );
}
