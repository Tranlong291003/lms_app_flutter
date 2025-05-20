import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lms/apps/config/api_config.dart';

class InfoTab extends StatelessWidget {
  final Map<String, dynamic> course;
  const InfoTab({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final radius12 = BorderRadius.circular(12);
    final screenWidth = MediaQuery.of(context).size.width;

    return ListView(
      padding: EdgeInsets.zero,
      physics: const ClampingScrollPhysics(),
      children: [
        // ---------- ẢNH THUMBNAIL ----------
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  course['thumbnail_url'] != null
                      ? CachedNetworkImage(
                        imageUrl:
                            course['thumbnail_url']!.startsWith('http')
                                ? course['thumbnail_url']!
                                : '${ApiConfig.baseUrl}${course['thumbnail_url']}',
                        fit: BoxFit.cover,
                        height: 180,
                        width: double.infinity,
                        placeholder:
                            (_, __) => Container(
                              color: colors.surfaceContainerHighest,
                              height: 180,
                            ),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: colors.surfaceContainerHighest,
                              height: 180,
                              child: const Icon(Icons.broken_image, size: 60),
                            ),
                      )
                      : Container(
                        color: colors.surfaceContainerHighest,
                        height: 180,
                        child: Icon(
                          Icons.image_outlined,
                          size: 60,
                          color: colors.primary.withOpacity(0.5),
                        ),
                      ),
            ),
          ),
        ),

        // ---------- TIÊU ĐỀ + ĐÁNH GIÁ ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                course['title'] ?? 'Không có tên',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Stars(rating: (course['rating'] ?? 0).toDouble()),
                  const SizedBox(width: 6),
                  Text(
                    (course['rating'] ?? 0).toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ---------- CHIP THÔNG TIN ----------
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.category,
                label: course['category_name'] ?? 'Chưa phân loại',
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.layers,
                label: course['level'] ?? 'Cơ bản',
                color: colors.secondary,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.language,
                label: course['language'] ?? 'Tiếng Việt',
                color: colors.tertiary,
              ),
            ],
          ),
        ),

        // ---------- GIÁ ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildPriceSection(course, colors),
        ),

        // ---------- MÔ TẢ ----------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            color: colors.surfaceContainerHighest,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                course['description'] ?? 'Không có mô tả',
                style: textTheme.bodyMedium,
              ),
            ),
          ),
        ),

        // ---------- THÔNG TIN KHÓA HỌC ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin khóa học',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoStatCard(
                    icon: Icons.people,
                    label: '${course['enrollment_count'] ?? 0} học viên',
                    color: colors.primary,
                  ),
                  const SizedBox(width: 12),
                  _InfoStatCard(
                    icon: Icons.menu_book,
                    label: '${course['lessons'] ?? 0} bài học',
                    color: colors.secondary,
                  ),
                  const SizedBox(width: 12),
                  _InfoStatCard(
                    icon: Icons.timer,
                    label: course['total_video_duration'] ?? '00:00:00',
                    color: colors.tertiary,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ---------- TAGS ----------
        if ((course['tags'] ?? '').toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tags',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      (course['tags'] as String)
                          .split(',')
                          .map(
                            (tag) => Chip(
                              label: Text(tag.trim()),
                              backgroundColor: colors.primary.withOpacity(.1),
                              labelStyle: textTheme.labelSmall,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Thêm widget hiển thị giá và giá khuyến mãi
  Widget _buildPriceSection(Map<String, dynamic> course, ColorScheme colors) {
    final price = course['price'];
    final discount = course['discount_price'];
    final hasDiscount = discount != null && discount > 0 && discount != price;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            hasDiscount
                ? '${NumberFormat.decimalPattern().format(discount)}đ'
                : price == null || price == 0
                ? 'Miễn phí'
                : '${NumberFormat.decimalPattern().format(price)}đ',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        if (hasDiscount) ...[
          const SizedBox(width: 8),
          Text(
            '${NumberFormat.decimalPattern().format(price)}đ',
            style: TextStyle(
              decoration: TextDecoration.lineThrough,
              color: colors.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  static String _formatDate(dynamic date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return date.toString();
    }
  }
}

// Thêm widget mới cho chip thông tin
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Widget con =======================
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: colors.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= .5;
    final empty = 5 - full - (half ? 1 : 0);

    List<Widget> icons = [
      for (int i = 0; i < full; i++)
        const Icon(Icons.star, size: 16, color: Colors.amber),
      if (half) const Icon(Icons.star_half, size: 16, color: Colors.amber),
      for (int i = 0; i < empty; i++)
        const Icon(Icons.star_border, size: 16, color: Colors.amber),
    ];
    return Row(children: icons);
  }
}

class _InfoStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoStatCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
