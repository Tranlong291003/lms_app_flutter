// lib/apps/widgets/courseCategory_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/category_model.dart';

class CourseCategoryWidget extends StatelessWidget {
  const CourseCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const LoadingIndicator();
        }
        if (state is CategoryError) {
          // Trước đây chỉ hiện một dòng "Lỗi: ..." nghiêng trái, không có cách
          // thử lại — người dùng phải thoát màn hình mới tải lại được danh mục.
          return SizedBox(
            height: 48,
            child: Center(
              child: TextButton.icon(
                onPressed: () => context.read<CategoryCubit>().fetchAllCategory(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Không tải được danh mục — Thử lại'),
              ),
            ),
          );
        }
        if (state is CategoryLoaded) {
          // Tạo thêm mục All với id = 0
          const allId = 0;
          final allCat = CourseCategory(categoryId: allId, name: '🔥 Tất cả');

          final cats = [allCat, ...state.categories];
          final selId = state.selectedId; // null => All

          // Chiều cao cố định 40px sẽ cắt chữ khi người dùng tăng cỡ chữ hệ
          // thống. Dùng chiều cao suy ra từ nội dung, có chặn trên/dưới.
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40, maxHeight: 64),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // Đệm thêm bên phải để chip cuối không dính sát mép và khi cuộn
              // hết vẫn thấy được viền chip.
              padding: const EdgeInsets.only(left: 16, right: 24),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final cat = cats[i];
                // nếu selectedId==null và cat.id==0 thì All được chọn;
                final isSelected =
                    (selId == null && cat.categoryId == allId) ||
                    (selId != null && cat.categoryId == selId);

                // Danh mục đang chọn: nền `secondaryContainer` (xanh nhạt) và
                // chữ `onSecondaryContainer` — trước đây là nền primary + chữ
                // trênPrimary, trùng hệt màu nút hành động nên chip trông như
                // một nút bấm chứ không phải trạng thái lọc.
                final selectedBg = theme.colorScheme.secondaryContainer;
                final selectedFg = theme.colorScheme.onSecondaryContainer;

                Widget iconWidget = const SizedBox.shrink();
                if (cat.icon?.isNotEmpty == true) {
                  final fullUrl = ApiConfig.getImageUrl(cat.icon);
                  iconWidget = Image.network(
                    fullUrl,
                    width: 16,
                    height: 16,
                    // Ảnh icon lỗi thì bỏ hẳn, không để lộ khung ảnh vỡ.
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    final newSel =
                        (cat.categoryId == allId) ? null : cat.categoryId;
                    context.read<CategoryCubit>().selectCategory(newSel);
                    // Gọi lại CourseCubit để lọc
                    context.read<CourseCubit>().loadCourses(categoryId: newSel);
                  },
                  child: Container(
                    // Vùng chạm tối thiểu 40px theo chiều cao: chip chỉ có
                    // padding 8px nên với chữ nhỏ sẽ thấp hơn ngón tay.
                    constraints: const BoxConstraints(minHeight: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? selectedBg : Colors.transparent,
                      borderRadius: AppRadius.borderPill,
                      border: Border.all(
                        color:
                            isSelected
                                ? selectedBg
                                : theme.colorScheme.outline,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (iconWidget is! SizedBox) ...[
                          iconWidget,
                          const SizedBox(width: 4),
                        ],
                        Text(
                          cat.name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? selectedFg
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        // initial / fallback
        return SizedBox(
          height: 40,
          child: Center(
            child: Text(
              'Không có danh mục nào',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
