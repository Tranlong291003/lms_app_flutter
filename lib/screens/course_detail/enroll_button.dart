import 'package:flutter/material.dart';
import 'package:lms/repository/course_repository.dart';
import 'package:lms/services/notification_service.dart';
import 'package:provider/provider.dart';

class EnrollButton extends StatefulWidget {
  final String userUid;
  final int courseId;
  const EnrollButton({
    super.key,
    required this.userUid,
    required this.courseId,
  });

  @override
  State<EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends State<EnrollButton> {
  bool _isRegistered = false;

  Future<void> _registerCourse(BuildContext context) async {
    try {
      final repository = context.read<CourseRepository>();
      final result = await repository.registerEnrollment(
        userUid: widget.userUid,
        courseId: widget.courseId,
      );
      if (result is Map && result['notification'] != null) {
        final notification = result['notification'];
        final notificationService = NotificationService();
        await notificationService.showNotification(
          notification['title'] ?? 'Đăng ký khoá học thành công',
          notification['body'] ?? 'Bạn đã đăng ký khoá học thành công!',
          notification['noti_id'] ??
              DateTime.now().millisecondsSinceEpoch % 100000,
        );
        setState(() => _isRegistered = true);
      } else if (result == true) {
        final notificationService = NotificationService();
        await notificationService.showNotification(
          'Đăng ký khoá học thành công',
          'Bạn đã đăng ký khoá học thành công!',
          DateTime.now().millisecondsSinceEpoch % 100000,
        );
        setState(() => _isRegistered = true);
      }
      // Không show SnackBar nữa
    } catch (e) {
      // Không show SnackBar nữa
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRegistered) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _registerCourse(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Đăng ký khoá học miễn phí',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
