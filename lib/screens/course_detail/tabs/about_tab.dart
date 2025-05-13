import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';

class AboutTab extends StatelessWidget {
  final String description;
  final String instructorName;
  final String? instructorAvatarUrl;
  final String? instructorBio;
  const AboutTab({
    super.key,
    required this.description,
    required this.instructorName,
    this.instructorAvatarUrl,
    this.instructorBio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Giảng viên',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      (instructorAvatarUrl != null &&
                              instructorAvatarUrl!.isNotEmpty)
                          ? NetworkImage(
                            ApiConfig.getImageUrl(instructorAvatarUrl),
                          )
                          : const AssetImage('assets/images/mentor.png')
                              as ImageProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructorName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (instructorBio != null && instructorBio!.isNotEmpty)
                      Text(
                        instructorBio!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Giới thiệu khoá học',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(
            'Công cụ sử dụng',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.network(
                'https://blog.greggant.com/images/posts/2019-04-25-figma/Figma.png',
                width: 20,
              ),
              const SizedBox(width: 8),
              Text('Figma', style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
