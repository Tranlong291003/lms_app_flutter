import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseTitle extends StatelessWidget {
  final String title;
  const CourseTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Icon(Icons.bookmark_border, color: theme.colorScheme.outline),
      ],
    );
  }
}
