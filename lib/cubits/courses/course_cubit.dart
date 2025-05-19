// lib/cubits/courses/course_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/course_repository.dart';

part 'course_detail_state.dart';
part 'course_state.dart';

/// Quản lý trạng thái và các thao tác với danh sách khóa học
///
/// Xử lý việc tải, lọc, và quản lý khóa học với các trạng thái khác nhau
/// (đã duyệt, đang chờ, bị từ chối)
class CourseCubit extends Cubit<CourseState> {
  final CourseRepository _repo;
  int? _categoryFilter;

  CourseCubit(this._repo) : super(const CourseInitial()) {
    loadCourses();
  }

  /// Tải danh sách khóa học với bộ lọc tùy chọn
  ///
  /// [categoryId] - Lọc theo ID danh mục
  /// [status] - Lọc theo trạng thái khóa học
  /// [search] - Từ khóa tìm kiếm khóa học
  Future<void> loadCourses({
    int? categoryId,
    String? status,
    String? search,
  }) async {
    emit(const CourseLoading());
    try {
      _categoryFilter = categoryId;
      final courseResponse = await _repo.getAllCourses(
        categoryId: categoryId,
        status: status,
        search: search,
      );

      _emitLoadedState(courseResponse);
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  /// Tải tất cả khóa học không có bộ lọc
  Future<void> fetchAllCourses() async {
    emit(const CourseLoading());
    try {
      final courseResponse = await _repo.getAllCourses();
      _emitLoadedState(courseResponse);
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  /// Phương thức hỗ trợ để chuẩn bị và emit trạng thái CourseLoaded
  void _emitLoadedState(CourseListResponse courseResponse) {
    final List<Course> approvedCourses = courseResponse.approved;
    final List<Course> pendingCourses = courseResponse.pending;
    final List<Course> rejectedCourses = courseResponse.rejected;

    // Kết hợp tất cả khóa học
    final allCourses = [
      ...approvedCourses,
      ...pendingCourses,
      ...rejectedCourses,
    ];

    // Tạo danh sách ngẫu nhiên từ khóa học đã duyệt
    final randomCourses = List<Course>.from(approvedCourses)..shuffle();

    emit(
      CourseLoaded(
        allCourses,
        randomCourses.take(10).toList(),
        approvedCourses: approvedCourses,
        pendingCourses: pendingCourses,
        rejectedCourses: rejectedCourses,
      ),
    );
  }

  /// Làm mới danh sách khóa học với bộ lọc hiện tại
  Future<void> refreshCourses() async {
    await loadCourses(categoryId: _categoryFilter);
  }

  /// Tìm kiếm khóa học theo chuỗi truy vấn
  Future<void> searchCourses(String query) async {
    await loadCourses(search: query, categoryId: _categoryFilter);
  }

  /// Phê duyệt một khóa học
  ///
  /// [courseId] - ID của khóa học cần phê duyệt
  /// [adminUid] - ID của admin thực hiện phê duyệt
  Future<void> approveCourse(int courseId, {required String adminUid}) async {
    try {
      await _repo.updateCourseStatus(
        courseId: courseId,
        status: 'approved',
        uid: adminUid,
      );
      await fetchAllCourses();
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  /// Từ chối một khóa học kèm lý do
  ///
  /// [courseId] - ID của khóa học cần từ chối
  /// [reason] - Lý do từ chối
  /// [adminUid] - ID của admin thực hiện từ chối
  Future<void> rejectCourse(
    int courseId,
    String reason, {
    required String adminUid,
  }) async {
    try {
      await _repo.updateCourseStatus(
        courseId: courseId,
        status: 'rejected',
        uid: adminUid,
        rejectionReason: reason,
      );
      await fetchAllCourses();
    } catch (e) {
      emit(CourseError(e.toString()));
    }
  }

  /// Làm mới lựa chọn khóa học ngẫu nhiên
  void refreshRandomCourses() {
    if (state is CourseLoaded) {
      final loaded = state as CourseLoaded;
      final newRandom = List<Course>.from(loaded.approvedCourses)..shuffle();
      emit(
        CourseLoaded(
          loaded.courses,
          newRandom.take(10).toList(),
          approvedCourses: loaded.approvedCourses,
          pendingCourses: loaded.pendingCourses,
          rejectedCourses: loaded.rejectedCourses,
        ),
      );
    }
  }

  /// Cập nhật trạng thái đánh dấu cho nhiều khóa học
  ///
  /// [courseIds] - Danh sách ID khóa học cần cập nhật
  /// [isBookmarked] - Trạng thái đánh dấu mới
  void updateBookmarkStatus(List<int> courseIds, bool isBookmarked) {
    if (state is CourseLoaded) {
      final loaded = state as CourseLoaded;

      // Hàm cập nhật cho danh sách khóa học
      List<Course> updateList(List<Course> courses) {
        return courses.map((course) {
          if (courseIds.contains(course.courseId)) {
            return course.copyWith(isBookmarked: isBookmarked);
          }
          return course;
        }).toList();
      }

      // Cập nhật tất cả danh sách khóa học
      final updatedCourses = updateList(loaded.courses);
      final updatedRandomCourses = updateList(loaded.randomCourses);
      final updatedApprovedCourses = updateList(loaded.approvedCourses);
      final updatedPendingCourses = updateList(loaded.pendingCourses);
      final updatedRejectedCourses = updateList(loaded.rejectedCourses);

      emit(
        CourseLoaded(
          updatedCourses,
          updatedRandomCourses,
          approvedCourses: updatedApprovedCourses,
          pendingCourses: updatedPendingCourses,
          rejectedCourses: updatedRejectedCourses,
        ),
      );
    }
  }

  /// Cập nhật trạng thái đánh dấu cho một khóa học
  ///
  /// [courseId] - ID của khóa học cần cập nhật
  /// [isBookmarked] - Trạng thái đánh dấu mới
  void updateCourseBookmarkStatus(int courseId, bool isBookmarked) {
    updateBookmarkStatus([courseId], isBookmarked);
  }
}

/// Quản lý trạng thái và thao tác với thông tin chi tiết khóa học
///
/// Xử lý việc tải và làm mới thông tin chi tiết cho một khóa học
class CourseDetailCubit extends Cubit<CourseDetailState> {
  final CourseRepository _repository;
  CourseDetailCubit(this._repository) : super(CourseDetailInitial());

  /// Tải thông tin chi tiết cho một khóa học cụ thể
  ///
  /// [courseId] - ID của khóa học cần tải thông tin chi tiết
  Future<void> fetchCourseDetail(int courseId) async {
    emit(CourseDetailLoading());
    try {
      final detail = await _repository.getCourseDetail(courseId);
      emit(CourseDetailLoaded(detail));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }

  /// Làm mới thông tin chi tiết khóa học
  ///
  /// Chỉ hoạt động khi đã ở trạng thái loaded
  void refreshCourseDetail() {
    if (state is CourseDetailLoaded) {
      final courseId = (state as CourseDetailLoaded).detail.courseId;
      fetchCourseDetail(courseId);
    }
  }
}
