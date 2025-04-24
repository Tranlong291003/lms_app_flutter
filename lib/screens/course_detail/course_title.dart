import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseTitle extends StatelessWidget {
  const CourseTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Giới thiệu về thiết kế UI/UX',
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Icon(Icons.bookmark_border, color: Colors.grey),
      ],
    );
  }
}
