// lib/services/category_service.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/services/base_service.dart';

class CategoryService extends BaseService {
  CategoryService() : super();

  /// `GET /api/course-categories` → `{ message, data: [...] }`
  Future<List<CourseCategory>> fetchAllCategory() async {
    try {
      final response = await get(ApiConfig.getAllCategory);

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) => CourseCategory.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }
      if (data is List) {
        return data
            .map(
              (json) => CourseCategory.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }
      throw Exception('Không thể tải danh sách danh mục');
    } on DioException catch (e) {
      debugPrint('CategoryService: fetchAllCategory lỗi: $e');
      throw Exception(
        'Không thể tải danh sách danh mục: ${extractApiError(e)}',
      );
    }
  }

  Future<void> createCategory({
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    try {
      final fields = <String, dynamic>{
        'name': name,
        'description': description,
        'uid': uid,
        if (icon != null)
          'icon': await MultipartFile.fromFile(
            icon.path,
            filename: icon.path.split(Platform.pathSeparator).last,
          ),
      };

      final response = await post(
        ApiConfig.createCategory,
        data: FormData.fromMap(fields),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Tạo danh mục thất bại');
      }
    } catch (e) {
      debugPrint('CategoryService: createCategory lỗi: $e');
      throw Exception(
        'Tạo danh mục thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  Future<void> deleteCategory(int categoryId, String uid) async {
    try {
      final response = await delete(
        ApiConfig.deleteCategory(categoryId),
        data: {'uid': uid},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Xóa danh mục thất bại');
      }
    } on DioException catch (e) {
      // 409: danh mục còn khóa học bên trong.
      if (e.response?.statusCode == 409) {
        throw Exception(
          extractApiError(
            e,
            fallback: 'Không thể xóa danh mục đang có khóa học',
          ),
        );
      }
      throw Exception('Xóa danh mục thất bại: ${extractApiError(e)}');
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    try {
      final fields = <String, dynamic>{
        'name': name,
        'description': description,
        'uid': uid,
        if (icon != null)
          'icon': await MultipartFile.fromFile(
            icon.path,
            filename: icon.path.split(Platform.pathSeparator).last,
          ),
      };

      final response = await put(
        ApiConfig.updateCategory(categoryId),
        data: FormData.fromMap(fields),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Cập nhật danh mục thất bại');
      }
    } catch (e) {
      debugPrint('CategoryService: updateCategory lỗi: $e');
      throw Exception(
        'Cập nhật danh mục thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }
}
