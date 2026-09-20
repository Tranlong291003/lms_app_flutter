import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/services/base_service.dart';

class BookmarkService extends BaseService {
  BookmarkService({super.token});

  /// `GET /api/bookmarks/:user_uid` → `{ data: [{ bookmark_id, course_id,
  /// course_title, course_thumbnail, created_at }] }`
  Future<List<BookmarkModel>> getBookmarksByUser(String userUid) async {
    try {
      final response = await get(ApiConfig.getBookmarksByUser(userUid));

      final data = response.data;
      if (data is Map && data['data'] is List) {
        return (data['data'] as List)
            .map(
              (json) => BookmarkModel.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        'Không thể tải danh sách bookmark: ${extractApiError(e)}',
      );
    }
  }

  /// `POST /api/bookmarks/create` body `{ courseId, userUid }`
  /// → `201 { data: { bookmark_id } }`
  Future<BookmarkModel> createBookmark({
    required int courseId,
    required String userUid,
  }) async {
    try {
      final response = await post(
        ApiConfig.createBookmark,
        data: {'courseId': courseId, 'userUid': userUid},
        options: Options(validateStatus: (status) => status == 201),
      );

      final data = response.data;
      if (data is Map && data['data'] is Map) {
        return BookmarkModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map),
        );
      }
      throw Exception('Máy chủ không trả về thông tin bookmark');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Khóa học này đã được lưu vào yêu thích');
      }
      throw Exception('Không thể lưu bookmark: ${extractApiError(e)}');
    }
  }

  /// `DELETE /api/bookmarks/delete` body `{ bookmarkId, userUid }` → `200 { data: null }`
  Future<bool> deleteBookmark({
    required int bookmarkId,
    required String userUid,
  }) async {
    try {
      final response = await delete(
        ApiConfig.deleteBookmark,
        data: {'bookmarkId': bookmarkId, 'userUid': userUid},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Không thể xóa bookmark: ${extractApiError(e)}');
    }
  }
}
