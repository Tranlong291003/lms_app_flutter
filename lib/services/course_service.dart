import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/courses/course_detail_model.dart';
import 'package:lms/models/courses/courses_model.dart';
import 'package:lms/services/base_service.dart';

/// Service xử lý tất cả các yêu cầu API liên quan đến khóa học
class CourseService extends BaseService {
  CourseService({super.token});

  /// Lấy danh sách khóa học với bộ lọc tùy chọn
  ///
  /// [status] - Lọc khóa học theo trạng thái (approved, pending, rejected)
  /// [categoryId] - Lọc khóa học theo ID danh mục
  /// [search] - Tìm kiếm khóa học theo từ khóa
  ///
  /// Trả về [CourseListResponse] chứa danh sách khóa học theo trạng thái
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

    try {
      final response = await get(
        ApiConfig.getAllCourses,
        queryParameters: params.isEmpty ? null : params,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data == null) {
          print('[CourseService] API trả về dữ liệu null');
          return _emptyResponse();
        }

        if (data is Map<String, dynamic>) {
          try {
            return CourseListResponse.fromJson(data);
          } catch (parseError) {
            print(
              '[CourseService] Lỗi khi phân tích dữ liệu JSON: $parseError',
            );
            return _emptyResponse();
          }
        }

        print(
          '[CourseService] Định dạng dữ liệu không chính xác. Kiểu: ${data.runtimeType}, dữ liệu: $data',
        );
        return _emptyResponse();
      }

      print('[CourseService] API trả về mã trạng thái: ${response.statusCode}');
      return _emptyResponse();
    } catch (e) {
      print('[CourseService] Lỗi khi tải danh sách khóa học: $e');
      return _emptyResponse();
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
      final data = {'userUid': userUid, 'courseId': courseId};
      final response = await post(ApiConfig.registerEnrollment, data: data);

      if (response.data is Map && response.data['notification'] != null) {
        return response.data;
      }
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (e is DioException && e.response != null) {
        throw Exception(
          'Đăng ký thất bại: ${e.response?.data?['message'] ?? e}',
        );
      }
      throw Exception('Đăng ký thất bại: $e');
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
    final data = {
      'status': status,
      'uid': uid,
      if (rejectionReason?.isNotEmpty ?? false)
        'rejectionReason': rejectionReason,
    };

    final response = await patch(
      '${ApiConfig.getAllCourses}/$courseId/status',
      data: data,
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.data['message'] ?? 'Cập nhật trạng thái thất bại',
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
