import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms/widgets/bookmark_button.dart';

class CourseTitle extends StatelessWidget {
  final String title;
  final int courseId;

  const CourseTitle({super.key, required this.title, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final userUid = currentUser?.uid ?? '';

    // Kích thước cố định cho nút bookmark
    const double buttonSize = 24;
    const double containerSize = 40;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
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
        SizedBox(
          width: containerSize,
          height: containerSize,
          child: Center(
            child:
                userUid.isNotEmpty
                    ? BookmarkButton(
                      courseId: courseId,
                      userUid: userUid,
                      size: buttonSize,
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.bookmark_border,
                        size: buttonSize,
                        color: theme.colorScheme.outline,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng đăng nhập để lưu khóa học'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: 'Đăng nhập để lưu khóa học',
                      constraints: const BoxConstraints(
                        minWidth: buttonSize,
                        minHeight: buttonSize,
                        maxWidth: buttonSize,
                        maxHeight: buttonSize,
                      ),
                      padding: EdgeInsets.zero,
                    ),
          ),
        ),
      ],
    );
  }
}
