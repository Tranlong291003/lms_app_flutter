// lib/blocs/cubit/courses/course_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repository/course_repository.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _repo;
  int? _categoryFilter;

  CourseCubit()
    : _repo = CourseRepository(Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))),
      super(const CourseInitial()) {
    loadCourses();
  }

  /// Load courses với filter tùy chọn
  Future<void> loadCourses({
    int? categoryId,
    String? status,
    String? search,
  }) async {
    emit(const CourseLoading());
    try {
      _categoryFilter = categoryId;
      final courses = await _repo.getAllCourses(
        categoryId: categoryId,
        status: status,
        search: search,
      );
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}
