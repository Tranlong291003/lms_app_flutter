// lib/apps/widgets/courseCategory_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
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
          return SizedBox(
            height: 40,
            child: Center(
              child: Text(
                'Lỗi: ${state.message}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          );
        }
        if (state is CategoryLoaded) {
          // Tạo thêm mục All với id = 0
          const allId = 0;
          final allCat = CourseCategory(categoryId: allId, name: 'Tất cả');

          final cats = [allCat, ...state.categories];
          final selId = state.selectedId; // null => All

          return SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final cat = cats[i];
                // nếu selectedId==null và cat.id==0 thì All được chọn;
                final isSelected =
                    (selId == null && cat.categoryId == allId) ||
                    (selId != null && cat.categoryId == selId);

                Widget iconWidget = const SizedBox.shrink();
                if (cat.icon?.isNotEmpty == true) {
                  final fullUrl = ApiConfig.getImageUrl(cat.icon);
                  iconWidget = Image.network(
                    fullUrl ?? '',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.20,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ]
                            : null,
                  ),
                  child: Material(
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        print(
                          'Chọn danh mục: id=${cat.categoryId}, name=${cat.name}',
                        );
                        final newSel =
                            (cat.categoryId == allId) ? null : cat.categoryId;
                        context.read<CategoryCubit>().selectCategory(newSel);
                        // Gọi lại CourseCubit để lọc
                        context.read<CourseCubit>().loadCourses(
                          categoryId: newSel,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline.withOpacity(
                                      0.12,
                                    ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (iconWidget is! SizedBox) iconWidget,
                            if (iconWidget is! SizedBox)
                              const SizedBox(width: 4),
                            Text(
                              cat.name,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    isSelected
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
