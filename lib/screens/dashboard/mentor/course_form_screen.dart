import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/widgets/custom_snackbar.dart';

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
  final _languageController = TextEditingController();
  final _tagsController = TextEditingController();
  XFile? _thumbnail;
  String? _thumbnailUrl;
  String _selectedLevel = 'Cơ bản';
  final List<String> _levels = ['Cơ bản', 'Trung bình', 'Nâng cao'];
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
      // Đảm bảo _selectedCategoryId luôn là int
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
      _priceController.text = d['price']?.toString() ?? '';
      _discountPriceController.text = d['discount_price']?.toString() ?? '';
      _languageController.text = d['language']?.toString() ?? '';
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
    _languageController.dispose();
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

        // DEBUG: Log chi tiết trước khi submit
        print('===== DEBUG: Trước khi submit =====');
        print(
          'category_id: $_selectedCategoryId ([33m${_selectedCategoryId.runtimeType}[0m)',
        );
        print(
          'price: [36m${_priceController.text}[0m ([33m${_priceController.text.runtimeType}[0m)',
        );
        print(
          'discount_price: [36m${_discountPriceController.text}[0m ([33m${_discountPriceController.text.runtimeType}[0m)',
        );
        print(
          'level: $_selectedLevel ([33m${_selectedLevel.runtimeType}[0m)',
        );
        print(
          'language: ${_languageController.text} ([33m${_languageController.text.runtimeType}[0m)',
        );
        print(
          'tags: ${_tagsController.text} ([33m${_tagsController.text.runtimeType}[0m)',
        );
        print(
          'uid: ${currentUser.uid} ([33m${currentUser.uid.runtimeType}[0m)',
        );
        print('thumbnail: ${_thumbnail?.path}');
        print('===================================');

        // Chuẩn bị dữ liệu gửi lên API
        final Map<String, dynamic> apiData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category_id': categoryId, // Đảm bảo là int
          'level': _selectedLevel,
          'price': int.tryParse(_priceController.text.trim()) ?? 0,
          'discount_price':
              int.tryParse(_discountPriceController.text.trim()) ?? 0,
          'language': _languageController.text.trim(),
          'tags': _tagsController.text.trim(),
          'uid': currentUser.uid,
          'status': 'pending',
        };

        // Thêm thumbnail nếu có
        if (_thumbnail != null) {
          apiData['thumbnail'] = File(_thumbnail!.path);
        }

        // DEBUG: Log map gửi lên API
        print('===== DEBUG: MAP gửi lên API =====');
        apiData.forEach((k, v) => print('$k: $v ([33m${v.runtimeType}[0m)'));
        print('==================================');

        // DEBUG: In ra JSON gửi lên API
        final logData = Map<String, dynamic>.from(apiData);
        if (logData['thumbnail'] is File) {
          logData['thumbnail'] = logData['thumbnail'].path;
        }
        print('===== DEBUG: COURSE CREATE JSON =====');
        print(jsonEncode(logData));
        print('======================================');

        // Hiển thị loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        if (widget.isEdit && widget.initialData != null) {
          // TODO: Implement update course API
          // Tạm thời giả lập thành công
          Navigator.of(context).pop(); // Đóng dialog loading
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Đã cập nhật khóa học thành công',
          );
          Navigator.of(context).pop(true); // Trở về màn hình trước
        } else {
          // Tạo khóa học mới
          await context.read<CourseCubit>().createCourse(apiData);

          // Đóng dialog loading
          Navigator.of(context).pop();

          // Hiển thị thông báo thành công
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Đã tạo khóa học mới thành công!',
          );

          // Trở về màn hình trước
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        // Đóng dialog loading nếu đang hiển thị
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        // Hiển thị lỗi
        CustomSnackBar.showError(
          context: context,
          message: 'Không thể lưu khóa học: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Sửa khóa học' : 'Thêm khóa học'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child:
                      _thumbnail != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(_thumbnail!.path),
                              height: 140,
                              width: 240,
                              fit: BoxFit.cover,
                            ),
                          )
                          : (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty)
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _thumbnailUrl!,
                              height: 140,
                              width: 240,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          size: 40,
                                          color: colorScheme.primary
                                              .withOpacity(0.7),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Không tải được ảnh',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ),
                          )
                          : Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 40),
                          ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                _titleController,
                'Tên khóa học',
                Icons.title,
                validator:
                    (v) => v == null || v.isEmpty ? 'Nhập tên khóa học' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Mô tả',
                Icons.description,
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Nhập mô tả' : null,
              ),
              const SizedBox(height: 16),
              // Dropdown danh mục
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CategoryLoaded) {
                    _categories = state.categories;
                    // Nếu chưa có selected, set mặc định là phần tử đầu tiên
                    if (_selectedCategoryId == null && _categories.isNotEmpty) {
                      _selectedCategoryId = _categories[0].categoryId;
                      _selectedCategoryName = _categories[0].name;
                    } else if (_selectedCategoryId != null &&
                        _categories.isNotEmpty) {
                      // Đảm bảo _selectedCategoryId luôn là int
                      final found = _categories.where(
                        (c) => c.categoryId == _selectedCategoryId,
                      );
                      if (found.isEmpty) {
                        _selectedCategoryId = _categories[0].categoryId;
                        _selectedCategoryName = _categories[0].name;
                      }
                    }
                    return DropdownButtonFormField<int>(
                      value:
                          _selectedCategoryId is int
                              ? _selectedCategoryId
                              : int.tryParse(_selectedCategoryId.toString()),
                      items:
                          _categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat.categoryId, // luôn là int
                                  child: Text(cat.name),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value; // value là int
                            // Đảm bảo truy cập đúng index
                            final cat = _categories.firstWhere(
                              (c) => c.categoryId == value,
                              orElse: () => _categories[0],
                            );
                            _selectedCategoryName = cat.name;
                            print(
                              'DEBUG: Chọn danh mục: id=$value ([33m${value.runtimeType}[0m), name=${cat.name}',
                            );
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      validator: (v) => v == null ? 'Chọn danh mục' : null,
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16),
              // Dropdown trình độ
              DropdownButtonFormField<String>(
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
                decoration: InputDecoration(
                  labelText: 'Trình độ',
                  prefixIcon: const Icon(Icons.leaderboard),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Chọn trình độ' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _priceController,
                      'Giá',
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator:
                          (v) => v == null || v.isEmpty ? 'Nhập giá' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 16),
              _buildTextField(
                _languageController,
                'Ngôn ngữ',
                Icons.language,
                validator:
                    (v) => v == null || v.isEmpty ? 'Nhập ngôn ngữ' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _tagsController,
                'Tags (phân cách bằng dấu phẩy)',
                Icons.sell,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(widget.isEdit ? Icons.save : Icons.add),
                  label: Text(widget.isEdit ? 'Lưu thay đổi' : 'Tạo khóa học'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
    );
  }
}
