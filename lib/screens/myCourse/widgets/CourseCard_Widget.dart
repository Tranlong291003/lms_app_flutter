import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String thumbnail;
  final String title;
  final String duration;
  final double progressValue;
  final Color progressColor;
  final String progressText;
  final bool showCircular;

  const CourseCard({
    super.key,
    required this.thumbnail,
    required this.title,
    required this.duration,
    required this.progressValue,
    required this.progressColor,
    required this.progressText,
    required this.showCircular,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color(0xFF1F222A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PHẦN ẢNH
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnail,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 80,
                  width: 80,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // PHẦN TEXT (Chiếm phần lớn không gian)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (!showCircular) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progressValue,
                    color: progressColor,
                    backgroundColor: Colors.grey.shade300,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    progressText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ],
            ),
          ),

          // PHẦN BIỂU ĐỒ TRÒN TO
          if (showCircular)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: SizedBox(
                height: 100, // Increased size by 25% (from 80 to 100)
                width: 100, // Increased size by 25% (from 80 to 100)
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth:
                          6, // Increased stroke width (thickness of the circle)
                      color: progressColor,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Text(
                      "${(progressValue * 100).round()}%",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
