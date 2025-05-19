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

      // Cập nhật tất cả các danh sách khóa học
      final updatedCourses = updateList(loaded.courses);
      final updatedRandomCourses = updateList(loaded.randomCourses);
      final updatedApprovedCourses = updateList(loaded.approvedCourses);
      final updatedPendingCourses = updateList(loaded.pendingCourses);
      final updatedRejectedCourses = updateList(loaded.rejectedCourses);

      // Emit trạng thái mới
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

  /// Lấy danh sách khóa học của giảng viên (mentor)
  ///
  /// [instructorUid] - ID của giảng viên cần lấy khóa học
  /// [status] - Trạng thái khóa học để lọc (tùy chọn)
  ///
  /// Trả về danh sách các đối tượng [Course]
  Future<List<Course>> getMentorCourses(
    String instructorUid, {
    String? status,
  }) async {
    try {
      emit(CourseLoading());
      final courses = await _repo.getCoursesByInstructor(
        instructorUid,
        status: status,
      );
      return courses;
    } catch (e) {
      emit(CourseError(e.toString()));
      return [];
    }
  }

  /// Gửi lại khóa học đã bị từ chối để duyệt lại
  ///
  /// [courseId] - ID khóa học cần gửi lại
  /// [instructorUid] - ID của mentor sở hữu khóa học
  ///
  /// Cập nhật trạng thái của khóa học từ rejected thành pending
  Future<void> resubmitCourse(
    int courseId, {
    required String instructorUid,
  }) async {
    try {
      await _repo.updateCourseStatus(
        courseId: courseId,
        status: 'pending',
        uid: instructorUid,
      );
    } catch (e) {
      emit(CourseError(e.toString()));
      rethrow;
    }
  }

  /// Tạo khóa học mới
  ///
  /// [data] - Map chứa thông tin khóa học, với các trường:
  /// - title: Tên khóa học (bắt buộc)
  /// - description: Mô tả khóa học (bắt buộc)
  /// - category_id: ID danh mục (bắt buộc)
  /// - price: Giá khóa học
  /// - discount_price: Giá khuyến mãi
  /// - level: Cấp độ khóa học
  /// - thumbnail: File ảnh thumbnail
  /// - language: Ngôn ngữ khóa học
  /// - tags: Tags của khóa học
  /// - instructor_uid: ID của mentor (bắt buộc)
  ///
  /// Không trả về ID, chỉ cần thành công là đủ
  Future<void> createCourse(Map<String, dynamic> data) async {
    try {
      emit(CourseLoading());
      await _repo.createCourse(data);
      await fetchAllCourses(); // Refresh danh sách khóa học sau khi tạo mới
    } catch (e) {
      emit(CourseError(e.toString()));
      rethrow;
    }
  }

  Future<void> updateCourse(int courseId, Map<String, dynamic> data) async {
    try {
      emit(CourseLoading());
      await _repo.updateCourse(courseId, data);
      await fetchAllCourses();
    } catch (e) {
      emit(CourseError(e.toString()));
      rethrow;
    }
  }

  /// Xóa khóa học theo ID
  ///
  /// [courseId] - ID của khóa học cần xóa
  /// [instructorUid] - ID của giảng viên sở hữu khóa học
  ///
  /// Nếu xóa thành công, cập nhật state bằng cách loại bỏ khóa học đã xóa
  Future<void> deleteCourse({
    required int courseId,
    required String instructorUid,
  }) async {
    try {
      emit(CourseLoading());
      await _repo.deleteCourse(
        courseId: courseId,
        instructorUid: instructorUid,
      );

      // Cập nhật state bằng cách loại bỏ khóa học đã xóa
      if (state is CourseLoaded) {
        final loaded = state as CourseLoaded;
        final updatedCourses =
            loaded.courses.where((c) => c.courseId != courseId).toList();
        final updatedRandomCourses =
            loaded.randomCourses.where((c) => c.courseId != courseId).toList();
        final updatedApprovedCourses =
            loaded.approvedCourses
                .where((c) => c.courseId != courseId)
                .toList();
        final updatedPendingCourses =
            loaded.pendingCourses.where((c) => c.courseId != courseId).toList();
        final updatedRejectedCourses =
            loaded.rejectedCourses
                .where((c) => c.courseId != courseId)
                .toList();

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
    } catch (e) {
      emit(CourseError(e.toString()));
      rethrow;
    }
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
