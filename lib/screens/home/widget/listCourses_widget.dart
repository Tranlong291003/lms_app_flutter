import 'package:flutter/material.dart';

class ListCoursesList extends StatelessWidget {
  const ListCoursesList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> courses = List.generate(
      10,
      (index) => {
        "title": "Khoá học Flutter số ${index + 1}",
        "thumbnail_url":
            "https://www.icantech.vn/_next/image?url=https%3A%2F%2Fs3.icankid.io%2Ficantech%2Fcms%2F1_3x_2dad764ee9.png&w=3840&q=100",
        "category": ["Thiết kế", "Lập trình", "Marketing"][index % 3],
        "price": 50 + index * 2,
        "discount_price": index % 2 == 0 ? 40 + index : null,
        "language": index % 2 == 0 ? "Tiếng Việt" : "Tiếng Anh",
        "level": ["Cơ bản", "Trung cấp", "Nâng cao"][index % 3],
      },
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course["thumbnail_url"],
                  height: 115,
                  width: 115,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category
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
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      course["title"],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        Text(
                          "\$$actualPrice",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F56DD),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        if (course["discount_price"] != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            "\$${course["price"]}",
                            style: const TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Language + Level
                    Text(
                      "${course["language"]}\nTrình độ: ${course["level"]}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.bookmark_border,
                  color: Color(0xFF2F56DD),
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
