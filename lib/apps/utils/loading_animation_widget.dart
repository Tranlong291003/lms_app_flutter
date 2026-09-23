import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Vòng xoay báo đang tải.
///
/// Widget này dùng ở hai ngữ cảnh rất khác nhau:
///  - phủ giữa màn hình (kích thước 24–48, có nền trắng + đổ bóng)
///  - nhét trong ô vuông nhỏ, ví dụ nút bookmark 24x24
///
/// Trước đây nó LUÔN cộng thêm `size * 0.42` padding mỗi bên, nên khi bị nhét
/// vào ô 24x24 thì vùng vẽ cần 24 + 20 = 44px → tràn layout và hiện sọc vàng
/// đen. Giờ kích thước được kẹp theo ràng buộc thực tế của ô chứa.
class LoadingIndicator extends StatelessWidget {
  final double size;

  /// Bỏ nền + đổ bóng khi cần nhúng vào chỗ chật.
  final bool plain;

  const LoadingIndicator({super.key, this.size = 24, this.plain = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Kẹp theo ô chứa: phần padding chiếm 42% mỗi bên nên tổng chiếm
        // ~1.84 lần `size`. Lấy tối đa 54% cạnh ngắn nhất để luôn vừa.
        final maxAllowed = constraints.hasBoundedHeight && constraints.hasBoundedWidth
            ? constraints.biggest.shortestSide * 0.54
            : double.infinity;
        final effective = size < maxAllowed ? size : maxAllowed;

        final dot = LoadingAnimationWidget.twistingDots(
          leftDotColor: theme.colorScheme.primary,
          rightDotColor: theme.colorScheme.secondary,
          size: effective,
        );

        // Chỗ quá chật (như nút bookmark) thì chỉ vẽ vòng xoay, không nền.
        if (plain || effective <= 0) {
          return Center(child: dot);
        }

        return Center(
          child: Container(
            padding: EdgeInsets.all(effective * 0.42),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surface.withOpacity(0.7)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(effective),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: dot,
          ),
        );
      },
    );
  }
}
