// lib/blocs/cubit/category/category_cubit.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/models/category_model.dart';
import 'package:lms/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;
  CategoryCubit(this.repository) : super(CategoryInitial());

  Future<void> fetchAllCategory() async {
    debugPrint('CategoryCubit: fetchAllCategory called');
    emit(CategoryLoading());
    try {
      final categories = await repository.fetchAllCategory();
      debugPrint(
        'CategoryCubit: fetchAllCategory loaded \\${categories.length} categories',
      );
      emit(CategoryLoaded(categories));
    } catch (e) {
      debugPrint('CategoryCubit: fetchAllCategory error: \\${e.toString()}');
      emit(CategoryError(e.toString()));
    }
  }

  /// User chọn 1 category (id null = All)
  void selectCategory(int? id) {
    final s = state;
    if (s is CategoryLoaded) {
      emit(CategoryLoaded(s.categories, selectedId: id));
    }
  }

  void refreshCategories() {
    fetchAllCategory();
  }

  Future<void> createCategory({
    required String name,
    required String description,
    required String uid,
    File? icon,
  }) async {
    debugPrint(
      'CategoryCubit: createCategory called with name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    emit(CategoryLoading());
    try {
      await repository.createCategory(
        name: name,
        description: description,
        uid: uid,
        icon: icon,
      );
      debugPrint(
        'CategoryCubit: createCategory success, fetching all categories',
      );
      await fetchAllCategory();
    } catch (e) {
      debugPrint('CategoryCubit: createCategory error: \\${e.toString()}');
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(int categoryId, String uid) async {
    debugPrint(
      'CategoryCubit: deleteCategory called with categoryId=$categoryId, uid=$uid',
    );
    emit(CategoryLoading());
    try {
      await repository.deleteCategory(categoryId, uid);
      debugPrint(
        'CategoryCubit: deleteCategory success, fetching all categories',
      );
      await fetchAllCategory();
    } catch (e) {
      debugPrint('CategoryCubit: deleteCategory error: ${e.toString()}');
      emit(CategoryError(e.toString()));
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
      'CategoryCubit: updateCategory called with categoryId=$categoryId, name=$name, description=$description, uid=$uid, icon=${icon?.path}',
    );
    emit(CategoryLoading());
    try {
      await repository.updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        uid: uid,
        icon: icon,
      );
      debugPrint(
        'CategoryCubit: updateCategory success, fetching all categories',
      );
      await fetchAllCategory();
    } catch (e) {
      debugPrint('CategoryCubit: updateCategory error: ${e.toString()}');
      emit(CategoryError(e.toString()));
    }
  }
}
