// lib/blocs/cubit/courses/course_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repository/course_repository.dart';

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
        status: 'true',
        search: search,
      );
      final randomCourses = List<Course>.from(courses)..shuffle();
      emit(CourseLoaded(courses, randomCourses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  void refreshCourses() {
    loadCourses();
  }

  void refreshRandomCourses() {
    if (state is CourseLoaded) {
      final loaded = state as CourseLoaded;
      final newRandom = List<Course>.from(loaded.courses)..shuffle();
      emit(CourseLoaded(loaded.courses, newRandom));
    }
  }

  // Cập nhật trạng thái bookmark cho courses
  void updateBookmarkStatus(List<int> courseIds, bool isBookmarked) {
    if (state is CourseLoaded) {
      final loaded = state as CourseLoaded;
      final updatedCourses =
          loaded.courses.map((course) {
            if (courseIds.contains(course.courseId)) {
              return course.copyWith(isBookmarked: isBookmarked);
            }
            return course;
          }).toList();

      final updatedRandomCourses =
          loaded.randomCourses.map((course) {
            if (courseIds.contains(course.courseId)) {
              return course.copyWith(isBookmarked: isBookmarked);
            }
            return course;
          }).toList();

      emit(CourseLoaded(updatedCourses, updatedRandomCourses));
    }
  }

  // Cập nhật trạng thái bookmark cho một course
  void updateCourseBookmarkStatus(int courseId, bool isBookmarked) {
    updateBookmarkStatus([courseId], isBookmarked);
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

  void refreshCourseDetail() {
    if (state is CourseDetailLoaded) {
      final courseId = (state as CourseDetailLoaded).detail.courseId;
      fetchCourseDetail(courseId);
    }
  }
}
