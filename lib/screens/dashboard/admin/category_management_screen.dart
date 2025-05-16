import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/apps/utils/searchBarWidget.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý danh mục'),
        backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
        foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Tìm kiếm danh mục...',
            onChanged: (value) {
              // TODO: Thực hiện tìm kiếm
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...List.generate(
                  10,
                  (index) => _buildCategoryCard(
                    context,
                    id: index + 1,
                    name: 'Danh mục ${index + 1}',
                    description: 'Mô tả danh mục ${index + 1}',
                    courseCount: (index + 1) * 5,
                    iconPath: null,
                  ),
                ),
              ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child:
              iconPath != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(iconPath), fit: BoxFit.cover),
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
                color: colorScheme.primaryContainer.withOpacity(0.1),
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

    if (iconPath != null) {
      selectedIcon = File(iconPath);
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final isDark = theme.brightness == Brightness.dark;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(maxWidth: 500),
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
                      child: Row(
                        children: [
                          Icon(
                            isEdit
                                ? Icons.edit_rounded
                                : Icons.add_circle_outline_rounded,
                            color: colorScheme.onPrimary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              isEdit
                                  ? 'Cập nhật danh mục'
                                  : 'Thêm danh mục mới',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.onPrimary
                                  .withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon picker
                            Center(
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color:
                                          selectedIcon != null
                                              ? Colors.transparent
                                              : colorScheme.primary.withOpacity(
                                                0.08,
                                              ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            selectedIcon != null
                                                ? Colors.transparent
                                                : colorScheme.primary
                                                    .withOpacity(0.2),
                                        width: 2,
                                      ),
                                      boxShadow:
                                          selectedIcon != null
                                              ? [
                                                BoxShadow(
                                                  color: colorScheme.shadow
                                                      .withOpacity(0.1),
                                                  blurRadius: 10,
                                                  spreadRadius: 0,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : null,
                                    ),
                                    child:
                                        selectedIcon != null
                                            ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.file(
                                                selectedIcon!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.image_rounded,
                                                  size: 48,
                                                  color: colorScheme.primary
                                                      .withOpacity(0.8),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Chọn icon',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: InkWell(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
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
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.shadow
                                                  .withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child:
                                            selectedIcon != null
                                                ? Icon(
                                                  Icons.edit_rounded,
                                                  color: colorScheme.onPrimary,
                                                  size: 20,
                                                )
                                                : Icon(
                                                  Icons
                                                      .add_photo_alternate_rounded,
                                                  color: colorScheme.onPrimary,
                                                  size: 20,
                                                ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Tên danh mục
                            Text(
                              'Tên danh mục',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: nameController,
                              hintText: 'Nhập tên danh mục',
                              maxLength: 20,
                              colorScheme: colorScheme,
                              prefixIcon: Icons.label_outline_rounded,
                              isDark: isDark,
                            ),

                            const SizedBox(height: 24),

                            // Mô tả
                            Text(
                              'Mô tả',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: descriptionController,
                              hintText: 'Nhập mô tả danh mục',
                              maxLines: 4,
                              colorScheme: colorScheme,
                              prefixIcon: Icons.description_outlined,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? colorScheme.surfaceContainerHighest
                                : colorScheme.surfaceContainer,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Hủy'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              side: BorderSide(color: colorScheme.outline),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () {
                              // TODO: Lưu danh mục vào cơ sở dữ liệu
                              // Đây là nơi sẽ thực hiện API call
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? 'Đã cập nhật danh mục "${nameController.text}"'
                                        : 'Đã thêm danh mục "${nameController.text}"',
                                  ),
                                  backgroundColor: colorScheme.primary,
                                ),
                              );
                            },
                            icon: Icon(isEdit ? Icons.save : Icons.add),
                            label: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required ColorScheme colorScheme,
    required bool isDark,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color:
              isDark
                  ? colorScheme.outline.withOpacity(0.2)
                  : colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              prefixIcon,
              color: colorScheme.primary.withOpacity(0.8),
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counter: const SizedBox.shrink(),
        ),
      ),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'Bạn có chắc chắn muốn xóa danh mục '),
                TextSpan(
                  text: name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Xóa danh mục từ cơ sở dữ liệu
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa danh mục "$name"'),
                    backgroundColor: colorScheme.error,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
