import 'package:flutter/material.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        final review = reviews[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review['name']! as String,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            review['date']! as String,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                        review['rating']! as int,
                        (_) => Icon(
                          Icons.star,
                          color: theme.colorScheme.secondary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review['comment']! as String,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
