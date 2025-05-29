import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/category_model.dart';

class CourseFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool isEdit;
  const CourseFormScreen({super.key, this.initialData, this.isEdit = false});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _levelController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _tagsController = TextEditingController();
  XFile? _thumbnail;
  String? _thumbnailUrl;
  String _selectedLevel = 'Cơ bản';
  String _selectedLanguage = 'Tiếng Việt';
  final List<String> _levels = ['Cơ bản', 'Trung bình', 'Nâng cao'];
  final List<String> _languages = [
    'Tiếng Việt',
    'Tiếng Anh',
    'Tiếng Trung',
    'Tiếng Nhật',
    'Tiếng Hàn',
    'Tiếng Pháp',
    'Tiếng Đức',
    'Tiếng Nga',
    'Tiếng Tây Ban Nha',
    'Tiếng Bồ Đào Nha',
    'Tiếng Ý',
    'Tiếng Thái',
    'Tiếng Indonesia',
    'Tiếng Malaysia',
    'Khác',
  ];
  List<CourseCategory> _categories = [];
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      print('===== DEBUG: initialData =====');
      d.forEach((k, v) => print('$k: $v ([33m${v.runtimeType}[0m)'));
      print('==============================');
      _titleController.text = d['title']?.toString() ?? '';
      _descriptionController.text = d['description']?.toString() ?? '';
      _selectedCategoryId = null;
      if (d['category_id'] != null) {
        final dynamic raw = d['category_id'];
        if (raw is int) {
          _selectedCategoryId = raw;
        } else if (raw is String) {
          final parsed = int.tryParse(raw);
          if (parsed != null) _selectedCategoryId = parsed;
        } else {
          final parsed = int.tryParse(raw.toString());
          if (parsed != null) _selectedCategoryId = parsed;
        }
      }
      _selectedCategoryName = d['category_name']?.toString();
      _selectedLevel = d['level']?.toString() ?? 'Cơ bản';
      _selectedLanguage = d['language']?.toString() ?? 'Tiếng Việt';
      _priceController.text = d['price']?.toString() ?? '';
      _discountPriceController.text = d['discount_price']?.toString() ?? '';
      _tagsController.text = d['tags']?.toString() ?? '';
      _thumbnailUrl =
          d['thumbnail_url']?.toString() ?? d['thumbnail']?.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _levelController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _thumbnail = picked;
        _thumbnailUrl = null;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Lấy UID của người dùng hiện tại
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('Bạn cần đăng nhập để tạo khóa học');
        }

        // Đảm bảo _selectedCategoryId là int
        final int? categoryId =
            _selectedCategoryId is int
                ? _selectedCategoryId
                : int.tryParse(_selectedCategoryId.toString());
        if (categoryId == null) {
          throw Exception('Danh mục không hợp lệ');
        }

        // Chuẩn bị dữ liệu gửi lên API
        final Map<String, dynamic> apiData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category_id': categoryId,
          'level': _selectedLevel,
          'price': int.tryParse(_priceController.text.trim()) ?? 0,
          'discount_price':
              int.tryParse(_discountPriceController.text.trim()) ?? 0,
          'language': _selectedLanguage,
          'tags': _tagsController.text.trim(),
          'uid': currentUser.uid,
          'status': 'pending',
        };

        // Thêm thumbnail nếu có
        if (_thumbnail != null) {
          apiData['thumbnail'] = File(_thumbnail!.path);
        }

        // Hiển thị loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: LoadingIndicator()),
        );

        if (widget.isEdit && widget.initialData != null) {
          final courseId =
              widget.initialData!['id'] ?? widget.initialData!['course_id'];
          await context.read<CourseCubit>().updateCourse(courseId, apiData);

          // Đóng dialog loading
          if (context.mounted) {
            Navigator.of(context).pop(); // Đóng dialog loading
            CustomSnackBar.showSuccess(
              context: context,
              message: 'Đã cập nhật khóa học thành công',
            );
            // Pop về màn hình trước và truyền true để báo hiệu cần refresh
            Navigator.of(context).pop({'refresh': true});
          }
        } else {
          // Tạo khóa học mới
          await context.read<CourseCubit>().createCourse(apiData);

          // Đóng dialog loading
          if (context.mounted) {
            Navigator.of(context).pop(); // Đóng dialog loading
            CustomSnackBar.showSuccess(
              context: context,
              message: 'Đã tạo khóa học mới thành công!',
            );
            // Pop về màn hình trước và truyền true để báo hiệu cần refresh
            Navigator.of(context).pop({'refresh': true});
          }
        }
      } catch (e) {
        // Đóng dialog loading nếu đang hiển thị
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Hiển thị lỗi
        if (context.mounted) {
          CustomSnackBar.showError(
            context: context,
            message: 'Không thể lưu khóa học: ${e.toString()}',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isEdit ? 'Sửa khóa học' : 'Thêm khóa học',
        showBack: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceContainerHighest.withOpacity(0.3),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail Section
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 180,
                          width: 320,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child:
                              _thumbnail != null
                                  ? Image.file(
                                    File(_thumbnail!.path),
                                    fit: BoxFit.cover,
                                  )
                                  : (_thumbnailUrl != null &&
                                      _thumbnailUrl!.isNotEmpty)
                                  ? Image.network(
                                    _thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildThumbnailPlaceholder(
                                              colorScheme,
                                            ),
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 48,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Thêm ảnh bìa khóa học',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin khóa học',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField(
                        _titleController,
                        'Tên khóa học',
                        Icons.title,
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Nhập tên khóa học'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _descriptionController,
                        'Mô tả',
                        Icons.description,
                        maxLines: 3,
                        validator:
                            (v) => v == null || v.isEmpty ? 'Nhập mô tả' : null,
                      ),
                      const SizedBox(height: 20),
                      // Category Dropdown
                      BlocBuilder<CategoryCubit, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(child: LoadingIndicator());
                          }
                          if (state is CategoryLoaded) {
                            _categories = state.categories;
                            if (_selectedCategoryId == null &&
                                _categories.isNotEmpty) {
                              _selectedCategoryId = _categories[0].categoryId;
                              _selectedCategoryName = _categories[0].name;
                            } else if (_selectedCategoryId != null &&
                                _categories.isNotEmpty) {
                              final found = _categories.where(
                                (c) => c.categoryId == _selectedCategoryId,
                              );
                              if (found.isEmpty) {
                                _selectedCategoryId = _categories[0].categoryId;
                                _selectedCategoryName = _categories[0].name;
                              }
                            }
                            return _buildDropdownField(
                              value: _selectedCategoryId,
                              items:
                                  _categories
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat.categoryId,
                                          child: Text(cat.name),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedCategoryId = value;
                                    final cat = _categories.firstWhere(
                                      (c) => c.categoryId == value,
                                      orElse: () => _categories[0],
                                    );
                                    _selectedCategoryName = cat.name;
                                  });
                                }
                              },
                              label: 'Danh mục',
                              icon: Icons.category,
                              validator:
                                  (v) => v == null ? 'Chọn danh mục' : null,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 20),
                      // Level Dropdown
                      _buildDropdownField(
                        value: _selectedLevel,
                        items:
                            _levels
                                .map(
                                  (level) => DropdownMenuItem(
                                    value: level,
                                    child: Text(level),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLevel = value;
                            });
                          }
                        },
                        label: 'Trình độ',
                        icon: Icons.leaderboard,
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Chọn trình độ' : null,
                      ),
                      const SizedBox(height: 20),
                      // Price Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _priceController,
                              'Giá',
                              Icons.attach_money,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) =>
                                      v == null || v.isEmpty
                                          ? 'Nhập giá'
                                          : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              _discountPriceController,
                              'Giá KM',
                              Icons.discount,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Language Dropdown
                      _buildDropdownField(
                        value: _selectedLanguage,
                        items:
                            _languages
                                .map(
                                  (language) => DropdownMenuItem(
                                    value: language,
                                    child: Text(language),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedLanguage = value;
                            });
                          }
                        },
                        label: 'Ngôn ngữ',
                        icon: Icons.language,
                        validator:
                            (v) =>
                                v == null || v.isEmpty ? 'Chọn ngôn ngữ' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        _tagsController,
                        'Tags (phân cách bằng dấu phẩy)',
                        Icons.sell,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Submit Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      widget.isEdit ? Icons.save : Icons.add,
                      size: 24,
                    ),
                    label: Text(
                      widget.isEdit ? 'Lưu thay đổi' : 'Tạo khóa học',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Không tải được ảnh',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String label,
    required IconData icon,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dropdownColor: colorScheme.surface,
      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      borderRadius: BorderRadius.circular(16),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      keyboardType: keyboardType,
      validator: validator,
      textAlignVertical: TextAlignVertical.top,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
