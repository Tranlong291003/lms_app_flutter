import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/blocs/cubit/category/category_cubit.dart';
import 'package:lms/blocs/cubit/category/category_state.dart';

class CourseCategoryWidget extends StatelessWidget {
  const CourseCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return LoadingIndicator();
        }
        if (state is CategoryError) {
          return SizedBox(
            height: 40,
            child: Center(child: Text('Lỗi: ${state.message}')),
          );
        }
        if (state is CategoryLoaded) {
          final cats = state.categories;
          final selId = state.selectedId;

          return SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: cats.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
                final cat = cats[i];
                final isSelected = cat.categoryId == selId;

                // Xác định widget cho icon
                Widget iconWidget = const SizedBox.shrink();
                final icon = cat.icon;
                if (icon != null && icon.isNotEmpty) {
                  // Nếu icon đã là URL đầy đủ thì xài luôn,
                  // còn không thì prefix bằng ApiConfig.baseUrl
                  final fullUrl =
                      icon.contains(RegExp(r'^https?://'))
                          ? icon
                          : '${ApiConfig.baseUrl}$icon';

                  iconWidget = Image.network(
                    fullUrl,
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    context.read<CategoryCubit>().selectCategory(
                      cat.categoryId,
                    );
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
