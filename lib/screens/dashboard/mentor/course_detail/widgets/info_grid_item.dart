import 'package:flutter/material.dart';

class InfoGridItem extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Color? color;
  final FontWeight? fontWeight;

  const InfoGridItem(
    this.icon,
    this.text, {
    super.key,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.isEmpty) return const SizedBox();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text!,
            style: TextStyle(color: color, fontWeight: fontWeight),
          ),
        ),
      ],
    );
  }
}
