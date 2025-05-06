// lib/widgets/list_courses_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/courses_model.dart';

class ListCoursesWidget extends StatelessWidget {
  final List<Course> courses;
  const ListCoursesWidget({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final priceFmt = NumberFormat('#,###');
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final c = courses[i];
        final actualPrice = c.discountPrice > 0 ? c.discountPrice : c.price;

        return Container(
          height: 140,
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
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${ApiConfig.baseUrl}${c.thumbnailUrl}' ?? '',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tags
                        Row(
                          children: [
                            _tag(
                              c.categoryName,
                              const Color(0xFFE6ECFD),
                              const Color(0xFF2F56DD),
                            ),
                            const SizedBox(width: 8),
                            _tag(
                              c.level,
                              _getLevelColor(c.level),
                              Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Title
                        Text(
                          c.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 6),

                        // Price row
                        Row(
                          children: [
                            Text(
                              "${priceFmt.format(actualPrice)} VND",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F56DD),
                              ),
                            ),
                            if (c.discountPrice > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                "${priceFmt.format(c.price)} VND",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Rating and Enroll count
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              c.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.person, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${c.enrollCount} người học',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Bookmark
              Positioned(
                top: 0,
                right: 0,
                child: BookmarkButton(initialSaved: false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }

  static Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'cơ bản':
        return Colors.green.shade400;
      case 'trung cấp':
        return Colors.orange.shade400;
      case 'nâng cao':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }
}

class BookmarkButton extends StatefulWidget {
  final bool initialSaved;
  const BookmarkButton({super.key, this.initialSaved = false});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  late bool isSaved;
  @override
  void initState() {
    super.initState();
    isSaved = widget.initialSaved;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        color: const Color(0xFF2F56DD),
      ),
      onPressed: () => setState(() => isSaved = !isSaved),
    );
  }
}
