// lib/apps/widgets/courseCategory_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/cubit/category/category_cubit.dart';
import 'package:lms/blocs/cubit/category/category_state.dart';
import 'package:lms/blocs/cubit/courses/course_cubit.dart';
import 'package:lms/models/category_model.dart';

class CourseCategoryWidget extends StatelessWidget {
  const CourseCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const LoadingIndicator();
        }
        if (state is CategoryError) {
          return SizedBox(
            height: 40,
            child: Center(child: Text('Lỗi: ${state.message}')),
          );
        }
        if (state is CategoryLoaded) {
          // Tạo thêm mục All với id = 0
          const allId = 0;
          final allCat = CourseCategory(categoryId: allId, name: '🔥 Tất cả');

          final cats = [allCat, ...state.categories];
          final selId = state.selectedId; // null => All

          return SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final cat = cats[i];
                // nếu selectedId==null và cat.id==0 thì All được chọn;
                final isSelected =
                    (selId == null && cat.categoryId == allId) ||
                    (selId != null && cat.categoryId == selId);

                Widget iconWidget = const SizedBox.shrink();
                if (cat.icon?.isNotEmpty == true) {
                  final fullUrl =
                      (cat.icon != null && cat.icon!.startsWith('http'))
                          ? cat.icon
                          : '${ApiConfig.baseUrl}${cat.icon}';
                  iconWidget = Image.network(
                    fullUrl ?? '',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    print(
                      'Chọn danh mục: id=${cat.categoryId}, name=${cat.name}',
                    );
                    final newSel =
                        (cat.categoryId == allId) ? null : cat.categoryId;
                    context.read<CategoryCubit>().selectCategory(newSel);
                    // Gọi lại CourseCubit để lọc
                    context.read<CourseCubit>().loadCourses(categoryId: newSel);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF2F56DD)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2F56DD),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (iconWidget is! SizedBox) iconWidget,
                        if (iconWidget is! SizedBox) const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF2F56DD),
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
        return const SizedBox(
          height: 40,
          child: Center(child: Text('Không có danh mục nào')),
        );
      },
    );
  }
}
