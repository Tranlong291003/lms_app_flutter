import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class AlwaysMarqueeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int numberOfRounds;
  final double maxWidth;

  const AlwaysMarqueeText({
    super.key,
    required this.text,
    required this.maxWidth,
    this.style,
    this.numberOfRounds = 2,
  });

  @override
  Widget build(BuildContext context) {
    final styleFinal =
        style ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

    return SizedBox(
      width: maxWidth,
      height: 20,
      child: Marquee(
        text: text,
        style: styleFinal,
        velocity: 30,
        blankSpace: 32,
        numberOfRounds: numberOfRounds,
        pauseAfterRound: const Duration(seconds: 1),
        showFadingOnlyWhenScrolling: false,
        startPadding: 0,
      ),
    );
  }
}
