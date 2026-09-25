import 'dart:io';

import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/services/base_service.dart';

/// Cấp độ khóa học hợp lệ theo API (`beginner | intermediate | advanced`).
const List<String> kCourseLevels = ['beginner', 'intermediate', 'advanced'];

/// Nhãn tiếng Việt tương ứng để hiển thị trên UI.
const Map<String, String> kCourseLevelLabels = {
  'beginner': 'Cơ bản',
  'intermediate': 'Trung cấp',
  'advanced': 'Nâng cao',
};

/// Đổi giá trị hiển thị ("Cơ bản") sang giá trị API ("beginner").
/// Nếu giá trị đã đúng chuẩn API thì giữ nguyên.
String normalizeCourseLevel(String? level) {
  final value = (level ?? '').trim();
  if (kCourseLevels.contains(value)) return value;

  switch (value.toLowerCase()) {
    case 'cơ bản':
    case 'co ban':
    case 'basic':
      return 'beginner';
    case 'trung cấp':
    case 'trung binh':
    case 'trung bình':
    case 'intermediate':
      return 'intermediate';
    case 'nâng cao':
    case 'nang cao':
    case 'advanced':
      return 'advanced';
    default:
      return 'beginner';
  }
}

/// Đổi giá trị API ("beginner") sang nhãn tiếng Việt để hiển thị.
String courseLevelLabel(String? level) {
  final value = (level ?? '').trim();
  return kCourseLevelLabels[value] ?? value;
}

/// Service xử lý tất cả các yêu cầu API liên quan đến khóa học
class CourseService extends BaseService {
  CourseService({super.token});

  /// Lấy danh sách khóa học với bộ lọc tùy chọn
  ///
  /// [status] - Lọc khóa học theo trạng thái (approved, pending, rejected)
  /// [categoryId] - Lọc khóa học theo ID danh mục
  /// [search] - Tìm kiếm khóa học theo từ khóa
  ///
  /// Trả về [CourseListResponse] chứa danh sách khóa học theo trạng thái.
  ///
  /// Ném ngoại lệ khi gọi API thất bại để tầng trên hiển thị trạng thái lỗi kèm
  /// nút "Thử lại". Trước đây hàm này nuốt mọi lỗi rồi trả danh sách rỗng, nên
  /// mất mạng lại hiện "Không có khoá học nào đang chờ duyệt" — người dùng hiểu
  /// sai là dữ liệu rỗng thay vì lỗi tải.
  Future<CourseListResponse> fetchAllCourses({
    String? status,
    int? categoryId,
    String? search,
  }) async {
    final params = <String, dynamic>{};
    if (status?.trim().isNotEmpty ?? false) {
      params['status'] = status!.trim();
    }
    if (categoryId != null) params['category'] = categoryId;
    if (search?.trim().isNotEmpty ?? false) {
      params['search'] = search!.trim();
    }

    final response = await get(
      ApiConfig.getAllCourses,
      queryParameters: params.isEmpty ? null : params,
    );

    if (response.statusCode != 200) {
      throw Exception('Máy chủ trả về mã ${response.statusCode}');
    }

    final data = response.data;
    // `GET /api/courses` trả `{ message: "Không có khóa học" }` khi CSDL rỗng —
    // đúng là rỗng, không phải lỗi.
    if (data == null) return _emptyResponse();
    if (data is Map<String, dynamic>) {
      return CourseListResponse.fromJson(data);
    }

    throw Exception('Dữ liệu khoá học trả về không đúng định dạng');
  }

  /// Lấy danh sách khóa học theo ID giảng viên
  ///
  /// [instructorUid] - ID của giảng viên cần lấy danh sách khóa học
  /// [status] - Lọc khóa học theo trạng thái (approved, pending, rejected) (tùy chọn)
  ///
  /// Trả về [List<Course>] chứa danh sách khóa học của giảng viên
  Future<List<Course>> getCoursesByInstructor(
    String instructorUid, {
    String? status,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (status?.trim().isNotEmpty ?? false) {
        params['status'] = status!.trim();
      }

      final response = await get(
        ApiConfig.getCoursesByInstructor(instructorUid),
        queryParameters: params.isEmpty ? null : params,
      );

      // DEBUG: In raw response từ API
      _debugLogRawResponse(response);

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is Map<String, dynamic>) {
          // Phân tích dữ liệu theo cấu trúc mới (danh sách phân loại theo trạng thái)
          final data = response.data['data'] as Map<String, dynamic>;
          final List<Course> results = [];

          // Xử lý danh sách đã duyệt
          if (data['approved'] is List) {
            results.addAll(_parseCoursesFromList(data['approved']));
          }

          // Xử lý danh sách chờ duyệt
          if (data['pending'] is List) {
            results.addAll(_parseCoursesFromList(data['pending']));
          }

          // Xử lý danh sách từ chối
          if (data['rejected'] is List) {
            results.addAll(_parseCoursesFromList(data['rejected']));
          }

          return results;
        }

        // Fallback cho cấu trúc cũ (danh sách đơn giản)
        if (response.data is Map<String, dynamic> &&
            response.data['data'] is List) {
          return _parseCoursesFromList(response.data['data']);
        }

        if (response.data is List) {
          return _parseCoursesFromList(response.data);
        }
      }

      print('[CourseService] API trả về mã trạng thái: ${response.statusCode}');
      return [];
    } catch (e) {
      print('[CourseService] Lỗi khi tải khóa học theo giảng viên: $e');
      return [];
    }
  }

  /// DEBUG: Phương thức ghi log raw response từ API
  void _debugLogRawResponse(Response response) {
    if (response.statusCode == 200) {
      print('\n===== DEBUG: RAW API RESPONSE =====');

      if (response.data is Map<String, dynamic>) {
        if (response.data['data'] is Map<String, dynamic>) {
          final data = response.data['data'] as Map<String, dynamic>;

          print('\nDữ liệu đã phân loại theo trạng thái:');
          print(
            '- Approved: ${data['approved'] is List ? (data['approved'] as List).length : 0} khóa học',
          );
          print(
            '- Pending: ${data['pending'] is List ? (data['pending'] as List).length : 0} khóa học',
          );
          print(
            '- Rejected: ${data['rejected'] is List ? (data['rejected'] as List).length : 0} khóa học',
          );

          if (data['approved'] is List &&
              (data['approved'] as List).isNotEmpty) {
            print('\nMẫu dữ liệu khóa học đã duyệt:');
            print(data['approved'][0]);
          }

          if (data['rejected'] is List &&
              (data['rejected'] as List).isNotEmpty) {
            print('\nMẫu dữ liệu khóa học bị từ chối:');
            print(data['rejected'][0]);
          }
        }
      }

      print('=======================================\n');
    }
  }

  /// Phương thức hỗ trợ tạo CourseListResponse trống
  CourseListResponse _emptyResponse() {
    return CourseListResponse(
      pending: [],
      approved: [],
      rejected: [],
      total: 0,
    );
  }

  /// Lấy thông tin chi tiết khóa học theo ID
  ///
  /// [courseId] - ID của khóa học cần lấy thông tin
  ///
  /// Trả về đối tượng [CourseDetail] hoặc ném ngoại lệ
  Future<CourseDetail> getCourseDetail(int courseId) async {
    try {
      final response = await get('${ApiConfig.getAllCourses}/$courseId');

      if (response.statusCode == 200 &&
          response.data['data'] is Map<String, dynamic>) {
        return CourseDetail.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      }
      throw Exception('Không thể tải thông tin chi tiết khóa học');
    } catch (e) {
      throw Exception('Lỗi khi tải thông tin chi tiết khóa học: $e');
    }
  }

  /// Kiểm tra người dùng đã đăng ký khóa học chưa
  ///
  /// [userUid] - ID độc nhất của người dùng
  /// [courseId] - ID của khóa học cần kiểm tra
  ///
  /// Trả về true nếu người dùng đã đăng ký, ngược lại false
  Future<bool> checkEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    try {
      final response = await get(ApiConfig.checkEnrollment(userUid, courseId));

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is bool) return data;
        if (data is Map<String, dynamic> && data.containsKey('enrolled')) {
          return data['enrolled'] == true;
        }
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Đăng ký người dùng vào khóa học
  ///
  /// [userUid] - ID độc nhất của người dùng
  /// [courseId] - ID của khóa học cần đăng ký
  ///
  /// Trả về dữ liệu thông báo nếu có, nếu không trả về trạng thái thành công
  Future<dynamic> registerEnrollment({
    required String userUid,
    required int courseId,
  }) async {
    try {
      final response = await post(
        ApiConfig.registerEnrollment,
        data: {'userUid': userUid, 'courseId': courseId},
        // 201 = đăng ký mới, 400 = đã đăng ký (được xử lý riêng bên dưới).
        options: Options(validateStatus: (status) => status == 201 || status == 400),
      );

      if (response.statusCode == 201) {
        return response.data is Map ? response.data : true;
      }

      final message = response.data is Map
          ? (response.data['error'] ?? response.data['message'])
          : null;
      throw Exception(
        message?.toString() ?? 'Bạn đã đăng ký khóa học này',
      );
    } catch (e) {
      throw Exception('Đăng ký thất bại: ${extractApiError(e, fallback: '$e')}');
    }
  }

  /// Tiến độ học của người dùng trong khóa học
  /// (`GET /api/enrollments/progress`).
  Future<Map<String, dynamic>> getCourseProgress({
    required String userUid,
    required int courseId,
  }) async {
    try {
      final response = await get(
        ApiConfig.getCourseProgress(userUid: userUid, courseId: courseId),
      );
      if (response.statusCode == 200 && response.data['data'] is Map) {
        return Map<String, dynamic>.from(response.data['data'] as Map);
      }
      return {};
    } catch (e) {
      print('[CourseService] Lỗi khi lấy tiến độ khóa học: $e');
      return {};
    }
  }

  /// Cập nhật trạng thái của khóa học
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
    try {
      final response = await patch(
        ApiConfig.updateCourseStatus(courseId),
        data: {
          'uid': uid,
          'status': status,
          if (rejectionReason?.isNotEmpty ?? false)
            'rejectionReason': rejectionReason,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          response.data is Map
              ? (response.data['error'] ?? response.data['message'])
              : 'Cập nhật trạng thái thất bại',
        );
      }
    } catch (e) {
      throw Exception(
        'Cập nhật trạng thái thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// Phương thức hỗ trợ phân tích danh sách khóa học từ JSON
  List<Course> _parseCoursesFromList(List jsonList) {
    try {
      return jsonList.map<Course>((item) => Course.fromJson(item)).toList();
    } catch (e) {
      print('[CourseService] Lỗi khi phân tích danh sách khóa học: $e');
      return [];
    }
  }

  /// Tạo khóa học mới
  ///
  /// [data] - Map chứa thông tin khóa học cần tạo, bao gồm:
  /// - title: Tên khóa học (bắt buộc)
  /// - description: Mô tả khóa học (bắt buộc)
  /// - category_id: ID danh mục (bắt buộc)
  /// - level: Cấp độ khóa học (cơ bản, trung bình, nâng cao)
  /// - price: Giá khóa học
  /// - discount_price: Giá khuyến mãi
  /// - thumbnail: File ảnh thumbnail (nếu có)
  /// - language: Ngôn ngữ khóa học
  /// - tags: Tags của khóa học
  /// - uid: ID của mentor tạo khóa học (bắt buộc)
  ///
  /// Không trả về ID, chỉ cần thành công là đủ
  Future<void> createCourse(Map<String, dynamic> data) async {
    try {
      // Tạo FormData nếu có file thumbnail
      final formData = FormData.fromMap(data);

      // Thêm thumbnail nếu có
      if (data['thumbnail'] != null && data['thumbnail'] is File) {
        final file = data['thumbnail'] as File;
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'thumbnail',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      // DEBUG: In thông tin request
      print('\n===== DEBUG: CREATE COURSE API REQUEST =====');
      print('URL: ${ApiConfig.createCourse}');
      print('Method: POST');
      print('Request body: ${formData.fields}');
      if (formData.files.isNotEmpty) {
        print('Files: ${formData.files.map((f) => f.key).join(', ')}');
      }
      print('=======================================\n');

      // Gửi request tạo khóa học
      final response = await post(ApiConfig.createCourse, data: formData);

      // DEBUG: In thông tin response
      print('\n===== DEBUG: CREATE COURSE API RESPONSE =====');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.data}');
      print('=======================================\n');

      // Kiểm tra response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(
        response.data is Map
            ? (response.data['error'] ?? response.data['message'])
            : 'Tạo khóa học thất bại với mã ${response.statusCode}',
      );
    } catch (e) {
      print('[CourseService] Lỗi khi tạo khóa học: $e');
      throw Exception(
        'Tạo khóa học thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  Future<void> updateCourse(int courseId, Map<String, dynamic> data) async {
    try {
      final formData = FormData.fromMap(data);
      if (data['thumbnail'] != null && data['thumbnail'] is File) {
        final file = data['thumbnail'] as File;
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'thumbnail',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }
      final response = await put(
        ApiConfig.updateCourse(courseId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          response.data is Map
              ? (response.data['error'] ?? response.data['message'])
              : 'Cập nhật khóa học thất bại',
        );
      }
    } catch (e) {
      throw Exception(
        'Cập nhật khóa học thất bại: ${extractApiError(e, fallback: '$e')}',
      );
    }
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
      final response = await delete(
        ApiConfig.deleteCourse(courseId),
        data: {'uid': instructorUid},
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception('Không thể xóa khóa học: ${response.statusMessage}');
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Lỗi khi xóa khóa học: ${e.response?.data?['message'] ?? e.message}',
        );
      }
      throw Exception('Lỗi khi xóa khóa học: $e');
    }
  }
}

/// Extension to add convenience methods to CourseListResponse
extension CourseListResponseExtension on CourseListResponse {
  /// Creates an empty CourseListResponse
  static CourseListResponse empty() {
    return CourseListResponse(
      pending: [],
      approved: [],
      rejected: [],
      total: 0,
    );
  }
}
