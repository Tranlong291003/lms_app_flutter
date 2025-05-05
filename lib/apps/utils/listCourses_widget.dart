import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListCoursesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final NumberFormat formatter = NumberFormat('#,###');

  ListCoursesWidget({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // padding: const EdgeInsets.all(12),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final course = courses[index];
        final int actualPrice = course["discount_price"] ?? course["price"];

        return Container(
          height: 150,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFFFFFFF)
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
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      course["thumbnail_url"],
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          width: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Row category + level
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6ECFD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  course["category"],
                                  style: const TextStyle(
                                    color: Color(0xFF2F56DD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getLevelColor(course["level"]),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  course["level"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Tiêu đề
                          Text(
                            course["title"],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Giá khuyến mãi & giá gốc
                          Row(
                            children: [
                              // ✅ Giá sale: luôn đủ
                              Text(
                                "${formatter.format(actualPrice)} VND",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F56DD),
                                  fontFamily: 'Roboto',
                                ),
                              ),

                              if (course["discount_price"] != null) ...[
                                const SizedBox(width: 8),

                                // 🔁 Giá gốc: co lại khi cần
                                Flexible(
                                  child: Text(
                                    "${formatter.format(course["price"])} VND",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontFamily: 'Roboto',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Ngôn ngữ
                          Text(
                            course["language"],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Bookmark Button có thể toggle
              Positioned(
                top: 0,
                right: 0,
                child: BookmarkButton(initialSaved: course["isSaved"] ?? false),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Màu tương ứng theo trình độ
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

/// Widget riêng cho nút lưu yêu thích

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
      onPressed: () {
        setState(() {
          isSaved = !isSaved;
        });
      },
    );
  }
}
