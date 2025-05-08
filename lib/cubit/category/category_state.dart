// lib/cubit/category_state.dart
import 'package:equatable/equatable.dart';
import 'package:lms/models/category_model.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<CourseCategory> categories;
  final int? selectedId;
  const CategoryLoaded(this.categories, {this.selectedId});

  @override
  List<Object?> get props => [categories, selectedId];
}

class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
