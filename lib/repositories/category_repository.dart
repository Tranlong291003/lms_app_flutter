// lib/repositories/category_repository.dart
import 'package:lms/models/category_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/category_service.dart';

class CategoryRepository extends BaseRepository<CategoryService> {
  CategoryRepository(super.service);

  /// Trả về list CourseCategory đã map sẵn
  Future<List<CourseCategory>> getAllCategories() async {
    final raw = await service.fetchAllCategory();
    return raw.map((json) => CourseCategory.fromJson(json)).toList();
  }
}
