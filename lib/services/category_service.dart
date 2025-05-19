// lib/services/category_service.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/services/base_service.dart';

class CategoryService extends BaseService {
  CategoryService() : super();

  /// Lấy danh sách tất cả category dưới dạng JSON Map
  Future<List<CourseCategory>> fetchAllCategory() async {
    debugPrint('CategoryService: fetchAllCategory called');
    final response = await get(ApiConfig.getAllCategory);
    debugPrint(
      'CategoryService: fetchAllCategory response: \\${response.data}',
    );
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((json) => CourseCategory.fromJson(json))
          .toList();
    }
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['data'] is List) {
        return (map['data'] as List)
            .map((json) => CourseCategory.fromJson(json))
            .toList();
      }
    }
    debugPrint('CategoryService: fetchAllCategory throw Exception');
    throw Exception('Không thể tải danh sách category');
  }

  Future<void> createCategory({
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    debugPrint(
      'CategoryService: createCategory called with name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'uid': uid,
      if (icon != null)
        'icon': await MultipartFile.fromFile(
          icon.path,
          filename: icon.path.split('/').last,
        ),
    });
    final response = await post(
      '${ApiConfig.baseUrl}/api/course-categories/create',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    debugPrint('CategoryService: createCategory response: \\${response.data}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('CategoryService: createCategory throw Exception');
      throw Exception('Tạo danh mục thất bại: ${response.data}');
    }
  }

  Future<void> deleteCategory(int categoryId, String uid) async {
    debugPrint(
      'CategoryService: deleteCategory called with categoryId=$categoryId, uid=$uid',
    );
    final url = '${ApiConfig.baseUrl}/api/course-categories/delete/$categoryId';
    final response = await delete(
      url,
      data: {'uid': uid},
      options: Options(contentType: 'application/json'),
    );
    debugPrint('CategoryService: deleteCategory response: ${response.data}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('CategoryService: deleteCategory throw Exception');
      throw Exception('Xóa danh mục thất bại: ${response.data}');
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    debugPrint(
      'CategoryService: updateCategory called with categoryId=$categoryId, name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'uid': uid,
      if (icon != null)
        'icon': await MultipartFile.fromFile(
          icon.path,
          filename: icon.path.split('/').last,
        ),
    });
    final url = '${ApiConfig.baseUrl}/api/course-categories/update/$categoryId';
    final response = await put(
      url,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    debugPrint('CategoryService: updateCategory response: ${response.data}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('CategoryService: updateCategory throw Exception');
      throw Exception('Cập nhật danh mục thất bại: ${response.data}');
    }
  }
}
