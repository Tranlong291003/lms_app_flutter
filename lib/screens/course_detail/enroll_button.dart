import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/course_card.dart' show formatVnd;
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/services/notification_service.dart';
import 'package:provider/provider.dart';

/// Nút đăng ký khoá học ở thanh dưới màn hình chi tiết khoá học.
class EnrollButton extends StatefulWidget {
  final String userUid;
  final int courseId;

  /// Giá gốc và giá khuyến mãi của khoá học. Trước đây nút luôn ghi "miễn phí"
  /// kể cả với khoá có phí, khiến người dùng không biết mình đang đăng ký khoá
  /// trả tiền.
  final int price;
  final int discountPrice;

  const EnrollButton({
    super.key,
    required this.userUid,
    required this.courseId,
    this.price = 0,
    this.discountPrice = 0,
  });

  @override
  State<EnrollButton> createState() => _EnrollButtonState();
}

class _EnrollButtonState extends State<EnrollButton> {
  bool _isRegistered = false;
  bool _isSubmitting = false;

  /// Hiện thông báo hệ thống khi API trả kèm nội dung.
  Future<void> _showSystemNotification(Object? result) async {
    try {
      final service = NotificationService();
      if (result is Map && result['notification'] is Map) {
        final n = result['notification'] as Map;
        await service.showNotification(
          n['title']?.toString() ?? 'Đăng ký khoá học thành công',
          n['body']?.toString() ?? 'Bạn đã đăng ký khoá học thành công!',
          n['noti_id'] is int
              ? n['noti_id'] as int
              : DateTime.now().millisecondsSinceEpoch % 100000,
        );
      } else {
        await service.showNotification(
          'Đăng ký khoá học thành công',
          'Bạn đã đăng ký khoá học thành công!',
          DateTime.now().millisecondsSinceEpoch % 100000,
        );
      }
    } catch (_) {
      // Thông báo hệ thống là phần phụ; không được làm hỏng luồng đăng ký.
    }
  }

  /// Nhãn nút theo giá thật của khoá học.
  String _label() {
    if (widget.price <= 0) return 'Đăng ký khoá học miễn phí';
    final effective =
        widget.discountPrice > 0 ? widget.discountPrice : widget.price;
    return 'Đăng ký khoá học · ${formatVnd(effective)} đ';
  }

  Future<void> _registerCourse() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Đọc xong `context` một lần rồi chỉ dùng lại biến `ctx`; trước mỗi lần
    // chạm tới nó sau `await` đều kiểm tra `ctx.mounted`.
    final ctx = context;
    final repository = ctx.read<CourseRepository>();
    try {
      final result = await repository.registerEnrollment(
        userUid: widget.userUid,
        courseId: widget.courseId,
      );

      // Repository trả `Map` khi API kèm dữ liệu thông báo, ngược lại là
      // `bool`. Trước đây chỉ đúng hai khuôn đó mới được coi là thành công;
      // mọi kết quả khác (ví dụ `Map` không có khoá 'notification') rơi vào
      // khoảng trống: không báo gì và nút cũng không đổi — người dùng bấm mà
      // tưởng app không phản hồi. Giờ coi là thất bại và nói rõ.
      final isFailure =
          result == false ||
          (result is Map &&
              (result['success'] == false || result['error'] != null));

      if (!ctx.mounted) return;

      if (isFailure) {
        setState(() => _isSubmitting = false);
        CustomSnackBar.showError(
          context: ctx,
          message: 'Đăng ký khoá học thất bại. Vui lòng thử lại.',
        );
        return;
      }

      setState(() {
        _isRegistered = true;
        _isSubmitting = false;
      });
      CustomSnackBar.showSuccess(
        context: ctx,
        message: 'Đăng ký khoá học thành công!',
      );
      await _showSystemNotification(result);
    } catch (_) {
      if (!ctx.mounted) return;
      setState(() => _isSubmitting = false);
      CustomSnackBar.showError(
        context: ctx,
        message: 'Không đăng ký được khoá học. Vui lòng thử lại.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRegistered) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _registerCourse,
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderPill),
        ),
        child:
            _isSubmitting
                ? SizedBox(
                  width: AppSpacing.xxl,
                  height: AppSpacing.xxl,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    // Nút bị vô hiệu hoá trong lúc gửi nên nền là màu xám
                    // nhạt; vòng xoay phải theo màu chữ của trạng thái đó chứ
                    // không phải màu trắng (sẽ chìm mất).
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                )
                : Text(_label(), style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
