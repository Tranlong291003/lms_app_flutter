import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';

class AboutTab extends StatelessWidget {
  final String description;
  final String instructorName;
  final String? instructorAvatarUrl;
  final String? instructorBio;
  final String language;
  final String tags;
  final String level;
  const AboutTab({
    super.key,
    required this.description,
    required this.instructorName,
    this.instructorAvatarUrl,
    this.instructorBio,
    required this.language,
    required this.tags,
    required this.level,
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
            'Thông tin khoá học',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Ngôn ngữ & Trình độ trên cùng một dòng
          Row(
            children: [
              Chip(
                avatar: Icon(
                  Icons.language,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  language,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: theme.colorScheme.surface,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Chip(
                avatar: Icon(
                  Icons.school,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  level,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                backgroundColor: theme.colorScheme.surface,
                shape: StadiumBorder(
                  side: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.2,
                  ),
                ),
              ),
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
          const SizedBox(height: 16),
          // Tags
          Text(
            'Tags',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ...tags
                  .split(',')
                  .map(
                    (tag) => Chip(
                      avatar: Icon(
                        Icons.tag,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        tag.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: theme.colorScheme.surface,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 24),
          // Lưu ý khi học khoá học Mindser
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Lưu ý khi học khoá học Mindser',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildNote(
                  theme,
                  'Học đều đặn mỗi ngày để đạt hiệu quả tốt nhất.',
                ),
                _buildNote(
                  theme,
                  'Chuẩn bị sổ ghi chú để ghi lại kiến thức quan trọng.',
                ),
                _buildNote(
                  theme,
                  'Tích cực tham gia thảo luận và hỏi đáp với giảng viên.',
                ),
                _buildNote(
                  theme,
                  'Xem lại các bài học trước khi làm bài kiểm tra.',
                ),
                _buildNote(theme, 'Đặt mục tiêu hoàn thành khoá học đúng hạn.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
