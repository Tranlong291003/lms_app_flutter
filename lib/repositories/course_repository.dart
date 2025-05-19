import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/course_service.dart';

/// Repository xử lý nghiệp vụ liên quan đến khóa học
///
/// Xử lý logic nghiệp vụ cho các khóa học, bao gồm lấy danh sách, lọc,
/// và quản lý đăng ký cũng như cập nhật trạng thái khóa học
class CourseRepository extends BaseRepository<CourseService> {
  CourseRepository(super.service);

  /// Lấy tất cả khóa học với bộ lọc tùy chọn
  ///
  /// [status] - Lọc khóa học theo trạng thái (approved, pending, rejected)
  /// [categoryId] - Lọc khóa học theo ID danh mục
  /// [search] - Tìm kiếm khóa học theo từ khóa
  ///
  /// Trả về [CourseListResponse] chứa danh sách khóa học theo trạng thái
  Future<CourseListResponse> getAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    return await service.fetchAllCourses(
      status: status,
      categoryId: categoryId,
      search: search,
    );
  }

  /// Lấy thông tin chi tiết về một khóa học cụ thể
  ///
  /// [courseId] - ID của khóa học cần lấy thông tin chi tiết
  ///
  /// Trả về đối tượng [CourseDetail] với thông tin đầy đủ về khóa học
  Future<CourseDetail> getCourseDetail(int courseId) async {
    return await service.getCourseDetail(courseId);
  }

  /// Đăng ký người dùng vào khóa học
  ///
  /// [userUid] - ID độc nhất của người dùng
  /// [courseId] - ID của khóa học cần đăng ký
  ///
  /// Trả về dữ liệu thông báo nếu có, ngược lại trả về trạng thái thành công
  Future<dynamic> registerEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    try {
      final result = await service.registerEnrollment(
        userUid: userUid,
        courseId: courseId,
      );

      // Trả về Map trực tiếp nếu chứa dữ liệu thông báo
      if (result is Map) {
        return result;
      }

      // Chuyển đổi kết quả sang boolean
      return result == true;
    } catch (e) {
      print('[CourseRepository] Lỗi đăng ký: $e');
      rethrow;
    }
  }

  /// Cập nhật trạng thái của khóa học (phê duyệt, từ chối, v.v.)
  ///
  /// [courseId] - ID của khóa học cần cập nhật
  /// [status] - Trạng thái mới (approved, pending, rejected)
  /// [uid] - ID người dùng thực hiện cập nhật
  /// [rejectionReason] - Lý do từ chối (bắt buộc khi status là 'rejected')
  Future<void> updateCourseStatus({
    required int courseId,
    required String status,
    required String uid,
    String? rejectionReason,
  }) async {
    await service.updateCourseStatus(
      courseId: courseId,
      status: status,
      uid: uid,
      rejectionReason: rejectionReason,
    );
  }

  /// Lấy danh sách khóa học được tạo bởi giảng viên cụ thể lọc theo trạng thái
  ///
  /// [instructorUid] - ID độc nhất của giảng viên
  /// [status] - Trạng thái để lọc khóa học (approved, pending, rejected)
  ///
  /// Trả về danh sách các đối tượng [Course]
}
