// lib/cubit/category_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:lms/repository/category_repository.dart';

import 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;
  CategoryCubit(this._repo) : super(const CategoryInitial());

  /// Load lần đầu hoặc reload
  Future<void> loadCategories() async {
    emit(const CategoryLoading());
    try {
      final cats = await _repo.getAllCategories();
      emit(CategoryLoaded(cats));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  /// User chọn 1 category
  void selectCategory(int id) {
    final s = state;
    if (s is CategoryLoaded) {
      emit(CategoryLoaded(s.categories, selectedId: id));
    }
  }
}
