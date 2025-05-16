import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  int? _selectedCategoryId;
  String? _selectedCategoryName;
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Lập trình Web'},
    {'id': 2, 'name': 'Lập trình Mobile'},
    {'id': 3, 'name': 'Khoa học Dữ liệu'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final d = widget.initialData!;
      _titleController.text = d['title'] ?? '';
      _descriptionController.text = d['description'] ?? '';
      _selectedCategoryId = d['category_id'] ?? 2;
      _selectedCategoryName =
          d['category_name'] ??
          _categories.firstWhere(
            (c) => c['id'] == _selectedCategoryId,
            orElse: () => _categories[0],
          )['name'];
      _selectedLevel = d['level'] ?? 'Cơ bản';
      _priceController.text = d['price']?.toString() ?? '';
      _discountPriceController.text = d['discount_price']?.toString() ?? '';
      _languageController.text = d['language'] ?? '';
      _tagsController.text = d['tags'] ?? '';
      _thumbnailUrl = d['thumbnail_url'] ?? d['thumbnail'];
    } else {
      _selectedCategoryId = _categories[0]['id'];
      _selectedCategoryName = _categories[0]['name'];
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Gửi dữ liệu lên backend hoặc Bloc
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category_id': _selectedCategoryId,
        'category_name': _selectedCategoryName,
        'level': _selectedLevel,
        'price': int.tryParse(_priceController.text.trim()) ?? 0,
        'discount_price':
            int.tryParse(_discountPriceController.text.trim()) ?? 0,
        'language': _languageController.text.trim(),
        'tags': _tagsController.text.trim(),
        'thumbnail_url':
            _thumbnail != null
                ? 'file://${_thumbnail!.path}' // Tạm thời, sẽ thay bằng URL thật sau khi upload
                : (_thumbnailUrl ?? 'https://via.placeholder.com/400x200'),
      };

      // Thêm các trường khác nếu là chỉnh sửa để không bị mất dữ liệu
      if (widget.isEdit && widget.initialData != null) {
        // Giữ lại các trường không thay đổi từ dữ liệu ban đầu
        data['enrollment_count'] = widget.initialData!['enrollment_count'] ?? 0;
        data['lessons'] = widget.initialData!['lessons'] ?? 0;
        data['rating'] = widget.initialData!['rating'] ?? 0.0;
        data['status'] = widget.initialData!['status'] ?? true;
        data['lessonsList'] = widget.initialData!['lessonsList'] ?? [];
        data['quizList'] = widget.initialData!['quizList'] ?? [];
      }

      Navigator.of(context).pop(data);
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
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                items:
                    _categories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat['id'] as int,
                            child: Text(cat['name'] as String),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoryId = value;
                      _selectedCategoryName =
                          _categories.firstWhere(
                            (c) => c['id'] == value,
                          )['name'];
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
