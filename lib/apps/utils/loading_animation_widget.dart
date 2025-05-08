import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  const LoadingIndicator({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color1 = theme.colorScheme.primary;
    final color2 = theme.colorScheme.secondary;
    final bgColor =
        isDark
            ? theme.colorScheme.surface.withOpacity(0.7)
            : Colors.white.withOpacity(0.85);
    return Center(
      child: Container(
        padding: EdgeInsets.all(size * 0.42),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: LoadingAnimationWidget.twistingDots(
          leftDotColor: color1,
          rightDotColor: color2,
          size: size,
        ),
      ),
    );
  }
}
