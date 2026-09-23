import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_theme.dart';

/// Màu ngữ nghĩa của theme hiện tại.
AppColors _c(BuildContext context) => AppColors.of(context);

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final TextStyle? style;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor ?? _c(context).neutral),
        const SizedBox(width: 4),
        Text(text, style: style),
      ],
    );
  }
}
