import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repository/course_repository.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _repo;
  CourseCubit()
    : _repo = CourseRepository(Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))),
      super(const CourseInitial()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    emit(const CourseLoading());
    try {
      final courses = await _repo.getAllCourses();
      emit(CourseLoaded(courses));
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }
}
