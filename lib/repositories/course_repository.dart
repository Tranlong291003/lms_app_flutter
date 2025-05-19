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
  Future<List<Course>> getCoursesByInstructor(
    String instructorUid, {
    String? status,
  }) async {
    try {
      final result = await service.getCoursesByInstructor(
        instructorUid,
        status: status,
      );

      // Debug: In dữ liệu JSON gốc
      debugLogCourseData();

      return result;
    } catch (e) {
      print(
        '[CourseRepository] Lỗi khi lấy danh sách khóa học của giảng viên: $e',
      );
      return [];
    }
  }

  /// Tạo khóa học mới
  ///
  /// [data] - Map chứa thông tin khóa học, với các trường:
  /// - title: Tên khóa học (bắt buộc)
  /// - description: Mô tả khóa học (bắt buộc)
  /// - category_id: ID danh mục (bắt buộc)
  /// - instructor_uid: ID của mentor (bắt buộc)
  /// - price: Giá khóa học
  /// - discount_price: Giá khuyến mãi
  /// - level: Cấp độ khóa học
  /// - thumbnail: File ảnh thumbnail
  /// - language: Ngôn ngữ khóa học
  /// - tags: Tags của khóa học
  ///
  /// Không trả về ID, chỉ cần thành công là đủ
  Future<void> createCourse(Map<String, dynamic> data) async {
    try {
      // Đảm bảo status là 'pending' cho khóa học mới
      if (!data.containsKey('status')) {
        data['status'] = 'pending';
      }

      await service.createCourse(data);
    } catch (e) {
      print('[CourseRepository] Lỗi khi tạo khóa học: $e');
      rethrow;
    }
  }

  /// Phương thức hỗ trợ để debug dữ liệu JSON gốc của khóa học
  void debugLogCourseData() {
    print('\n===== DEBUG: API RESPONSE RAW JSON =====');
    print('''
{
  "data": {
    "pending": [ ],
    "approved": [
      {
        "course_id": 3,
        "title": "Lập trình Flutter cơ bản",
        "description": "Khóa học dành cho người mới bắt đầu học Flutter",
        "instructor_uid": "aYWOOdd1MbdEamTWqRYKnEfNVE12",
        "category_id": 2,
        "price": 123,
        "level": "cơ bản",
        "discount_price": 123,
        "thumbnail_url": "/uploads/courses/course-1745294380603.jpg",
        "status": "approved",
        "rejection_reason": null,
        "updated_at": "2025-05-19T10:15:24.237Z",
        "instructor_name": "Nguyễn Ánh",
        "instructor_avatar": "/uploads/avatars/aYWOOdd1MbdEamTWqRYKnEfNVE12-1746605834660.jpg",
        "category_name": "Lập trình Mobile",
        "rating": 4,
        "enroll_count": 6,
        "lesson_count": 4,
        "total_duration": "04:14:24"
      }
    ],
    "rejected": [
      {
        "course_id": 4,
        "title": "test",
        "description": "Khóa học dành cho người mới bắt đầu học Flutter",
        "instructor_uid": "aYWOOdd1MbdEamTWqRYKnEfNVE12",
        "category_id": 2,
        "price": 200000,
        "level": "cơ bản",
        "discount_price": 150000,
        "thumbnail_url": null,
        "status": "rejected",
        "rejection_reason": "fgfgfg",
        "updated_at": "2025-05-19T12:22:14.280Z",
        "instructor_name": "Nguyễn Ánh",
        "instructor_avatar": "/uploads/avatars/aYWOOdd1MbdEamTWqRYKnEfNVE12-1746605834660.jpg",
        "category_name": "Lập trình Mobile",
        "rating": 0,
        "enroll_count": 1,
        "lesson_count": 0,
        "total_duration": "00:00:00"
      },
      {
        "course_id": 1004,
        "title": "Lập trình web cơ bản",
        "description": "Khóa học dành cho người mới bắt đầu học Flutter",
        "instructor_uid": "aYWOOdd1MbdEamTWqRYKnEfNVE12",
        "category_id": 3,
        "price": 200000,
        "level": "cơ bản",
        "discount_price": 150000,
        "thumbnail_url": null,
        "status": "rejected",
        "rejection_reason": "12312312321",
        "updated_at": "2025-05-19T10:16:27.587Z",
        "instructor_name": "Nguyễn Ánh",
        "instructor_avatar": "/uploads/avatars/aYWOOdd1MbdEamTWqRYKnEfNVE12-1746605834660.jpg",
        "category_name": "Lập trình web",
        "rating": 0,
        "enroll_count": 4,
        "lesson_count": 7,
        "total_duration": "01:06:11"
      }
    ]
  },
  "total": 3
}
''');
    print('=======================================\n');
  }

  Future<void> updateCourse(int courseId, Map<String, dynamic> data) async {
    await service.updateCourse(courseId, data);
  }

  /// Xóa khóa học theo ID
  ///
  /// [courseId] - ID của khóa học cần xóa
  /// [instructorUid] - ID của giảng viên sở hữu khóa học
  ///
  /// Trả về true nếu xóa thành công, ngược lại throw Exception
  Future<bool> deleteCourse({
    required int courseId,
    required String instructorUid,
  }) async {
    try {
      return await service.deleteCourse(
        courseId: courseId,
        instructorUid: instructorUid,
      );
    } catch (e) {
      print('[CourseRepository] Lỗi khi xóa khóa học: $e');
      rethrow;
    }
  }
}
