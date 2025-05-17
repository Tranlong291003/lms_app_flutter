import 'package:bloc/bloc.dart';
import 'package:lms/cubits/enrolled_courses/enrolled_course_state.dart';
import 'package:lms/models/enrolledCourse_model.dart';
import 'package:lms/repositories/enrolled_course_repository.dart';

class EnrolledCourseCubit extends Cubit<EnrolledCourseState> {
  final EnrolledCourseRepository _repository;
  List<EnrolledCourse> _allCourses = [];
  List<EnrolledCourse> _ongoingCourses = [];
  List<EnrolledCourse> _completedCourses = [];

  EnrolledCourseCubit({String? token})
    : _repository = EnrolledCourseRepository(token: token),
      super(const EnrolledCourseInitial());

  /// Lấy danh sách khóa học đã đăng ký của người dùng
  Future<void> loadEnrolledCourses(String userUid) async {
    print('[EnrolledCourseCubit] Bắt đầu tải khóa học cho user: $userUid');
    emit(const EnrolledCourseLoading());

    try {
      print('[EnrolledCourseCubit] Gọi repository để lấy dữ liệu');
      final result = await _repository.getEnrolledCourses(userUid);

      // Lấy danh sách khóa học từ kết quả
      _ongoingCourses = result['in_progress'] ?? [];
      _completedCourses = result['completed'] ?? [];
      _allCourses = [..._ongoingCourses, ..._completedCourses];

      print(
        '[EnrolledCourseCubit] Đã nhận được ${_allCourses.length} khóa học tổng cộng',
      );
      print(
        '[EnrolledCourseCubit] Chi tiết: ${_ongoingCourses.length} khóa học đang học, ${_completedCourses.length} khóa học đã hoàn thành',
      );

      emit(
        EnrolledCourseLoaded(
          allCourses: _allCourses,
          ongoingCourses: _ongoingCourses,
          completedCourses: _completedCourses,
        ),
      );
    } catch (e) {
      print('[EnrolledCourseCubit] Lỗi khi tải khóa học: $e');
      // Nếu có lỗi, vẫn hiển thị danh sách trống thay vì hiển thị màn hình lỗi
      emit(
        EnrolledCourseLoaded(
          allCourses: [],
          ongoingCourses: [],
          completedCourses: [],
        ),
      );
    }
  }

  void refreshEnrolledCourses(String userUid) {
    print('[EnrolledCourseCubit] Làm mới danh sách khóa học');
    loadEnrolledCourses(userUid);
  }

  /// Lấy danh sách khóa học đang học
  List<EnrolledCourse> getOngoingCourses() {
    if (state is EnrolledCourseLoaded) {
      return (state as EnrolledCourseLoaded).ongoingCourses;
    }
    return [];
  }

  /// Lấy danh sách khóa học đã hoàn thành
  List<EnrolledCourse> getCompletedCourses() {
    if (state is EnrolledCourseLoaded) {
      return (state as EnrolledCourseLoaded).completedCourses;
    }
    return [];
  }
}
