// lib/blocs/cubit/category/category_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:lms/repositories/category_repository.dart';

import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;
  CategoryCubit(this._repo) : super(const CategoryInitial());

  /// Load lần đầu hoặc reload
  Future<void> loadCategories() async {
    emit(const CategoryLoading());
    try {
      final cats = await _repo.getAllCategories();
      // Sau khi load xong, default selectedId = null (tức All)
      emit(CategoryLoaded(cats, selectedId: null));
    } catch (e) {
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
    loadCategories();
  }
}
