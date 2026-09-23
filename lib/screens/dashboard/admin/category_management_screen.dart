import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().fetchAllCategory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  String? _getIconUrl(String? icon) {
    if (icon == null || icon.isEmpty) return null;
    if (icon.startsWith('http')) return icon;
    return ApiConfig.baseUrl + icon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quản lý danh mục',
        showBack: true,
        showSearch: true,
        onSearchChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: LoadingIndicator());
                }
                if (state is CategoryError) {
                  // Trước đây chỉ một dòng "Lỗi: ..." không icon, không cách
                  // thử lại — người dùng phải thoát màn hình mới tải lại được.
                  return EmptyStateWidget(
                    icon: Icons.cloud_off_rounded,
                    title: 'Không tải được danh mục',
                    message: state.message,
                    isError: true,
                    actionLabel: 'Thử lại',
                    onAction: () =>
                        context.read<CategoryCubit>().fetchAllCategory(),
                  );
                }
                if (state is CategoryLoaded) {
                  final categories = state.categories;
                  final filteredCategories =
                      categories
                          .where(
                            (cat) =>
                                cat.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                  if (filteredCategories.isEmpty) {
                    // Phân biệt "chưa có danh mục nào" với "tìm không ra":
                    // trước đây cả hai đều là một dòng chữ giống nhau.
                    return _searchQuery.isEmpty
                        ? EmptyStateWidget(
                          icon: Icons.category_outlined,
                          title: 'Chưa có danh mục nào',
                          message:
                              'Nhấn nút + để tạo danh mục đầu tiên cho khoá học.',
                          actionLabel: 'Tạo danh mục',
                          onAction: () => _showCategoryDialog(context),
                        )
                        : EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'Không tìm thấy danh mục',
                          message: 'Không có danh mục nào khớp "$_searchQuery".',
                        );
                  }

                  return ListView.builder(
                    padding: listPaddingWithBottomInset(
                      context,
                      // Chừa chỗ cho nút "+" nổi ở góc dưới phải.
                      all: AppSpacing.lg,
                    ).copyWith(bottom: 88),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final cat = filteredCategories[index];
                      return _buildCategoryCard(
                        context,
                        id: cat.categoryId,
                        name: cat.name,
                        description: cat.description ?? '',
                        courseCount: cat.courseCount,
                        iconPath: cat.icon,
                      );
                    },
                  );
                }
                return const Center(child: LoadingIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required int id,
    required String name,
    required String description,
    required int courseCount,
    String? iconPath,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              _getIconUrl(iconPath) != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _getIconUrl(iconPath)!,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Icon(Icons.category, color: colorScheme.primary, size: 28),
        ),
        title: Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$courseCount khóa học',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed:
                  () => _showCategoryDialog(
                    context,
                    isEdit: true,
                    id: id,
                    name: name,
                    description: description,
                    iconPath: iconPath,
                  ),
              icon: const Icon(Icons.edit),
              color: colorScheme.primary,
            ),
            IconButton(
              onPressed: () {
                _showDeleteConfirmation(context, id, name);
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryDialog(
    BuildContext context, {
    bool isEdit = false,
    int? id,
    String name = '',
    String description = '',
    String? iconPath,
  }) async {
    final nameController = TextEditingController(text: name);
    final descriptionController = TextEditingController(text: description);
    File? selectedIcon;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;

            return Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEdit
                                    ? Icons.edit_rounded
                                    : Icons.add_circle_outline_rounded,
                                color: colorScheme.onPrimary,
                                size: 26,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEdit
                                    ? 'Cập nhật danh mục'
                                    : 'Thêm danh mục mới',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close_rounded),
                              color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme.onPrimary
                                    .withValues(alpha: 0.12),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 24),
                          // Icon picker
                          Center(
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        selectedIcon != null
                                            ? Colors.transparent
                                            : colorScheme.primary.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          selectedIcon != null
                                              ? colorScheme.primary
                                              : colorScheme.primary.withValues(alpha: 0.18),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      if (selectedIcon != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.file(
                                            selectedIcon!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else if (iconPath != null &&
                                          _getIconUrl(iconPath) != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.network(
                                            _getIconUrl(iconPath)!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image_rounded,
                                              size: 40,
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.7),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Chọn icon',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () async {
                                      final ImagePicker picker = ImagePicker();
                                      final XFile? image = await picker
                                          .pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 80,
                                          );
                                      if (image != null) {
                                        setState(() {
                                          selectedIcon = File(image.path);
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: colorScheme.shadow
                                                .withValues(alpha: 0.18),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        selectedIcon != null
                                            ? Icons.edit_rounded
                                            : Icons.add_photo_alternate_rounded,
                                        color: colorScheme.onPrimary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Tên danh mục
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Tên danh mục',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DescriptionTextField(
                            controller: nameController,
                            hintText: 'Nhập tên danh mục',
                            maxLength: 20,
                            maxLines: 1,
                            prefixIcon: Icons.label_outline_rounded,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(height: 22),
                          // Mô tả
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Mô tả',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          DescriptionTextField(
                            controller: descriptionController,
                            hintText: 'Nhập mô tả danh mục...',
                            maxLength: 500,
                            maxLines: 5,
                            prefixIcon: Icons.description_outlined,
                            colorScheme: colorScheme,
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  () => Navigator.of(dialogContext).pop(),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Hủy'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 14,
                                ),
                                side: BorderSide(color: colorScheme.outline),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () async {
                                final uid =
                                    context.read<AuthCubit>().state.userId ??
                                    '';
                                try {
                                  if (isEdit) {
                                    await context
                                        .read<CategoryCubit>()
                                        .updateCategory(
                                          categoryId: id!,
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          uid: uid,
                                          icon: selectedIcon,
                                        );
                                    if (mounted) {
                                      CustomSnackBar.showSuccess(
                                        context: context,
                                        message: 'Cập nhật danh mục thành công',
                                      );
                                    }
                                  } else {
                                    await context
                                        .read<CategoryCubit>()
                                        .createCategory(
                                          name: nameController.text,
                                          description:
                                              descriptionController.text,
                                          uid: uid,
                                          icon: selectedIcon,
                                        );
                                    if (mounted) {
                                      CustomSnackBar.showSuccess(
                                        context: context,
                                        message: 'Thêm danh mục mới thành công',
                                      );
                                    }
                                  }
                                  Navigator.of(dialogContext).pop();
                                } catch (_) {
                                  // Cubit giờ ném lại lỗi nên nhánh này mới
                                  // chạy được; trước đây nó là code chết và
                                  // hộp thoại luôn báo "Thành công".
                                  if (mounted) {
                                    CustomSnackBar.showError(
                                      context: context,
                                      message:
                                          isEdit
                                              ? 'Cập nhật danh mục thất bại. Vui lòng thử lại.'
                                              : 'Thêm danh mục thất bại. Vui lòng thử lại.',
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                isEdit ? Icons.save : Icons.add,
                                size: 18,
                              ),
                              label: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _showDeleteConfirmation(
    BuildContext context,
    int id,
    String name,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.error,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Xác nhận xoá danh mục',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    text: 'Bạn có chắc chắn muốn xoá danh mục ',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const TextSpan(text: ' ?'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(color: colorScheme.outline),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        try {
                          final uid =
                              context.read<AuthCubit>().state.userId ?? '';
                          await context.read<CategoryCubit>().deleteCategory(
                            id,
                            uid,
                          );
                          if (mounted) {
                            CustomSnackBar.showSuccess(
                              context: context,
                              message: 'Đã xóa danh mục "$name" thành công',
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            CustomSnackBar.showError(
                              context: context,
                              message: 'Xóa danh mục thất bại: ${e.toString()}',
                            );
                          }
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Xoá'),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DescriptionTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final IconData prefixIcon;
  final ColorScheme colorScheme;

  const DescriptionTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLength = 500,
    this.maxLines = 5,
    required this.prefixIcon,
    required this.colorScheme,
  });

  @override
  State<DescriptionTextField> createState() => _DescriptionTextFieldState();
}

class _DescriptionTextFieldState extends State<DescriptionTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      if (hasFocus) {
        HapticFeedback.lightImpact();
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              widget.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              widget.colorScheme.primaryContainer.withValues(alpha: 0.1),
              _animation.value,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Color.lerp(
                    widget.colorScheme.outline.withValues(alpha: 0.5),
                    widget.colorScheme.primary.withValues(alpha: 0.5),
                    _animation.value,
                  )!,
              width: 1 + (_animation.value * 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.colorScheme.shadow.withValues(
                  alpha: 0.05 * _animation.value,
                ),
                blurRadius: 8 * _animation.value,
                offset: Offset(0, 2 * _animation.value),
              ),
            ],
          ),
          child: Focus(
            onFocusChange: _handleFocusChange,
            child: TextField(
              controller: widget.controller,
              minLines: 1,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              style: TextStyle(
                color: widget.colorScheme.onSurface,
                fontSize: 16,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
                prefixIcon: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, right: 12),
                      child: Icon(
                        widget.prefixIcon,
                        color: Color.lerp(
                          widget.colorScheme.primary,
                          widget.colorScheme.primary.withValues(alpha: 0.8),
                          _animation.value,
                        ),
                        size: 22 + (_animation.value * 2),
                      ),
                    );
                  },
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 50),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.transparent,
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to update counter
              },
            ),
          ),
        );
      },
    );
  }
}
