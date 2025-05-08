// lib/blocs/cubit/courses/course_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repository/course_repository.dart';
import 'package:meta/meta.dart';

part 'course_detail_state.dart';
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

class CourseDetailCubit extends Cubit<CourseDetailState> {
  final CourseRepository _repository;
  CourseDetailCubit(this._repository) : super(CourseDetailInitial());

  Future<void> fetchCourseDetail(int courseId) async {
    emit(CourseDetailLoading());
    try {
      final detail = await _repository.getCourseDetail(courseId);
      print('DEBUG CourseDetailCubit loaded: \\${detail.toJson()}');
      emit(CourseDetailLoaded(detail));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }
}
