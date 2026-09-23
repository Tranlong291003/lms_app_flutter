import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/status_chip.dart' show StatusTone;

/// Đồng hồ đếm ngược của bài kiểm tra.
///
/// Màu đổi theo mức khẩn cấp và lấy từ bảng màu ngữ nghĩa của theme. Trước đây
/// hardcode `Colors.red/orange/green`: ba màu đó không nằm trong bảng màu app, và
/// `Colors.green` trên nền tối chỉ đạt ~2.6:1 — tức là lúc thời gian còn nhiều
/// lại là lúc khó đọc nhất.
class QuizTimer extends StatelessWidget {
  final int remainingSeconds;
  final VoidCallback onTimeUp;

  const QuizTimer({
    super.key,
    required this.remainingSeconds,
    required this.onTimeUp,
  });

  String _formatTime() {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Sắc thái theo thời gian còn lại: dưới 1 phút là nguy cấp, dưới 5 phút là
  /// sắp hết, còn lại là bình thường.
  StatusTone _tone() {
    if (remainingSeconds < 60) return StatusTone.error;
    if (remainingSeconds < 300) return StatusTone.warning;
    return StatusTone.success;
  }

  (Color fg, Color bg, Color border) _colors(BuildContext context) {
    final c = AppColors.of(context);
    final fg = switch (_tone()) {
      StatusTone.error => c.error,
      StatusTone.warning => c.warning,
      _ => c.success,
    };
    return (fg, fg.withValues(alpha: 0.12), fg.withValues(alpha: 0.35));
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg, border) = _colors(context);
    final isUrgent = remainingSeconds < 60;

    return Semantics(
      // Thời gian còn lại là thông tin quan trọng — công bố rõ cho trình đọc
      // màn hình thay vì chỉ đọc trơ ra "05:00".
      label: 'Thời gian còn lại ${_formatTime()}',
      liveRegion: isUrgent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.borderPill,
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUrgent ? Icons.timer_off_outlined : Icons.timer_outlined,
              color: fg,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _formatTime(),
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                // Chữ số đều nhau để đồng hồ không giật khi số thay đổi.
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
