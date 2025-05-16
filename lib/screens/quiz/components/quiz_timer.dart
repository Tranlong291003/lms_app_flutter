import 'package:flutter/material.dart';

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

  Color _getTimerColor() {
    if (remainingSeconds < 60) {
      return Colors.red;
    } else if (remainingSeconds < 300) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Color _getTimerBackgroundColor() {
    if (remainingSeconds < 60) {
      return Colors.red.withOpacity(0.2);
    } else if (remainingSeconds < 300) {
      return Colors.orange.withOpacity(0.2);
    } else {
      return Colors.green.withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimerColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getTimerColor().withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: _getTimerColor(), size: 20),
          const SizedBox(width: 8),
          Text(
            _formatTime(),
            style: TextStyle(
              color: _getTimerColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
