// lib/repositories/category_repository.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/services/category_service.dart';

class CategoryRepository {
  final CategoryService service;
  CategoryRepository(this.service);

  Future<List<CourseCategory>> fetchAllCategory() async {
    debugPrint('CategoryRepository: fetchAllCategory called');
    final result = await service.fetchAllCategory();
    debugPrint(
      'CategoryRepository: fetchAllCategory result: \\${result.length} categories',
    );
    return result;
  }

  Future<void> createCategory({
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    debugPrint(
      'CategoryRepository: createCategory called with name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    await service.createCategory(
      name: name,
      description: description,
      uid: uid,
      icon: icon,
    );
    debugPrint('CategoryRepository: createCategory done');
  }

  Future<void> deleteCategory(int categoryId, String uid) async {
    debugPrint(
      'CategoryRepository: deleteCategory called with categoryId=$categoryId, uid=$uid',
    );
    await service.deleteCategory(categoryId, uid);
    debugPrint('CategoryRepository: deleteCategory done');
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    debugPrint(
      'CategoryRepository: updateCategory called with categoryId=$categoryId, name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    await service.updateCategory(
      categoryId: categoryId,
      name: name,
      description: description,
      uid: uid,
      icon: icon,
    );
    debugPrint('CategoryRepository: updateCategory done');
  }
}
