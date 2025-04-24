import 'package:flutter/material.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = List.generate(
      4,
      (index) => {
        'name': 'Người dùng ${index + 1}',
        'rating': 5 - index,
        'comment':
            'Khoá học rất hay và hữu ích, kiến thức thực tiễn dễ áp dụng!',
        'date': '25/04/2025',
      },
    );

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final r = reviews[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (Theme.of(context).brightness == Brightness.light)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r['name']! as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          r['date']! as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      r['rating']! as int,
                      (_) =>
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                r['comment']! as String,
                style: const TextStyle(fontSize: 13.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
