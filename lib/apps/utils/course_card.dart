import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/bookmark_button.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/services/course_service.dart';

/// Thẻ khoá học dùng chung cho mọi danh sách (trang chủ, tìm kiếm, đã lưu).
///
/// Trước đây mỗi danh sách tự dựng một thẻ riêng, và chúng đã lệch nhau:
///  - thẻ ở trang chủ dùng `minHeight` + nhãn co giãn → không tràn;
///  - thẻ ở màn "đã lưu" dùng `height: 140` cứng trong khi ảnh 120 + đệm 24 =
///    144 → tràn 4px, và ở cỡ chữ lớn thì tràn nhiều hơn;
///  - thẻ ở "đã lưu" còn hiện tiêu đề 1 dòng (bị cắt) và nhãn cấp độ bằng
///    `Colors.orange`/`Colors.red` với chữ `onPrimary` → tương phản ~2.2:1.
///
/// Gom về một widget để mọi danh sách cùng một dáng, và mọi bản sửa bố cục chỉ
/// cần làm một lần.
class CourseCard extends StatelessWidget {
  final Course course;

  /// Uid người dùng hiện tại — rỗng thì nút lưu ở trạng thái chỉ đọc.
  final String userUid;

  final String? token;

  /// Cubit dùng chung với danh sách. Bắt buộc truyền để trạng thái lưu không
  /// lệch giữa các thẻ trong cùng một màn hình.
  final BookmarkCubit bookmarkCubit;

  /// Gọi khi người dùng BỎ lưu khoá học này, để danh sách tự loại thẻ ra.
  final ValueChanged<Course>? onUnbookmarked;

  const CourseCard({
    super.key,
    required this.course,
    required this.userUid,
    required this.bookmarkCubit,
    this.token,
    this.onUnbookmarked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final thumb = _thumbSize(context);

    return InkWell(
      borderRadius: AppRadius.borderLg,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.courseDetail,
          arguments: course.courseId,
        );
      },
      child: Container(
        // Ràng buộc chiều cao TỐI THIỂU thay vì `height` cố định: ảnh 120px
        // cộng đệm 24px đã là 144px, nên thẻ cao 140px tràn mất 4px; và khi
        // người dùng tăng cỡ chữ hệ thống thì phần chữ cần thêm chỗ.
        constraints: const BoxConstraints(minHeight: 144),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppRadius.borderLg,
          border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.borderMd,
                  child: _buildThumbnail(context, thumb),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cả hai nhãn đều phải co giãn được: tên danh mục dài
                      // ("Lập trình Web") cộng nhãn cấp độ vượt bề rộng còn
                      // lại của thẻ trên máy nhỏ → tràn ngang.
                      Row(
                        children: [
                          Flexible(
                            child: CourseTag(
                              label: course.categoryName,
                              background: scheme.primaryContainer,
                              foreground: scheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: CourseTag(
                              label: courseLevelLabel(course.level),
                              background: courseLevelColor(context, course.level),
                              foreground: scheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        // `clip` cắt ngang giữa chữ mà không có dấu "..." nên
                        // người dùng không biết tên bị cụt.
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs + 2),
                      _buildPriceRow(context),
                      const SizedBox(height: AppSpacing.xs + 2),
                      _buildStatsRow(context),
                    ],
                  ),
                ),
              ],
            ),

            // Nút lưu — nằm góc trên phải, đè lên nội dung.
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.8),
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: BookmarkButton(
                  courseId: course.courseId,
                  userUid: userUid,
                  token: token,
                  size: 20,
                  bookmarkCubit: bookmarkCubit,
                  onToggle: (isBookmarked) {
                    if (!isBookmarked) onUnbookmarked?.call(course);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, double size) {
    if (course.thumbnailUrl == null || course.thumbnailUrl!.isEmpty) {
      return _placeholder(context, size);
    }
    return Image.network(
      ApiConfig.getImageUrl(course.thumbnailUrl),
      width: size,
      height: size,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _placeholder(context, size);
      },
      errorBuilder: (_, __, ___) => _placeholder(context, size),
    );
  }

  /// Ảnh thu nhỏ co lại trên máy hẹp.
  ///
  /// Cố định 120px từng khiến cột chữ chỉ còn ~132px trên máy 320px, không đủ
  /// cho hàng nhãn + giá + đánh giá → tràn.
  double _thumbSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 88;
    if (width < 400) return 104;
    return 120;
  }

  Widget _placeholder(BuildContext context, double size) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 48,
          color: scheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        // Giá bán co giãn được: ở chữ lớn (x1.3) trên máy 320px, giá bán cộng
        // giá gốc vượt bề rộng còn lại nên tràn 40px nếu để cứng.
        Flexible(
          child: Text(
            course.displayPrice,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (course.discountPrice > 0 && course.price > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              '${formatVnd(course.price)} đ',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.star_rounded,
          size: 16,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            course.rating.toStringAsFixed(1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Icon(
          Icons.person_outline_rounded,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            '${course.enrollCount} người học',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Nhãn nhỏ (danh mục, cấp độ) trên thẻ khoá học.
class CourseTag extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const CourseTag({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        label,
        // Nhãn bị co lại (Flexible ở hàng nhãn) phải cắt bằng "..." thay vì
        // tràn chữ ra ngoài khung.
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Màu NỀN cho nhãn cấp độ khoá học.
///
/// Trả về cặp `*Container` của Material để chữ `onPrimaryContainer` nằm trên
/// luôn đủ tương phản — trước đây hai màn hình dùng hai bảng màu khác nhau
/// (`Colors.green/orange/red` ở màn "đã lưu" và `tertiary/secondary/error` ở
/// trang chủ), nên cùng một cấp độ hiển thị khác nhau tuỳ màn hình.
///
/// Nhận cả giá trị tiếng Anh (`beginner`) lẫn nhãn tiếng Việt để tương thích
/// dữ liệu cũ.
Color courseLevelColor(BuildContext context, String level) {
  final scheme = Theme.of(context).colorScheme;
  switch (normalizeCourseLevel(level)) {
    case 'beginner':
      return scheme.tertiaryContainer;
    case 'intermediate':
      return scheme.secondaryContainer;
    case 'advanced':
      return scheme.errorContainer;
    default:
      return scheme.surfaceContainerHighest;
  }
}

/// Định dạng tiền theo kiểu Việt Nam (phân cách nghìn bằng dấu chấm).
///
/// Trước đây có ba bản sao của phép biến đổi này rải ở các màn hình, trong đó
/// một chỗ dùng `NumberFormat('#,###')` cho ra "1,299,000" — hai định dạng khác
/// nhau nằm cạnh nhau trên cùng một thẻ.
String formatVnd(int amount) => amount.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]}.',
);
