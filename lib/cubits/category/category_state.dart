// lib/cubit/category_state.dart
part of 'category_cubit.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CourseCategory> categories;
  final int? selectedId;
  CategoryLoaded(this.categories, {this.selectedId});
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
