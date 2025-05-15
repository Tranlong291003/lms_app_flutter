import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/services/base_service.dart';

class BookmarkService extends BaseService {
  BookmarkService({super.token});

  Future<List<BookmarkModel>> getBookmarksByUser(String userUid) async {
    try {
      final response = await get(ApiConfig.getBookmarksByUser(userUid));
      print('Đã nhận dữ liệu bookmark: ${response.data}');

      final List<dynamic> data = response.data['data'];
      return data.map((json) => BookmarkModel.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách bookmark: $e');
      rethrow;
    }
  }

  Future<BookmarkModel> createBookmark({
    required int courseId,
    required String userUid,
  }) async {
    try {
      final data = {'courseId': courseId, 'userUid': userUid};

      print('Đang gửi request tạo bookmark với body: $data');
      final response = await post(
        ApiConfig.createBookmark,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 201,
        ),
      );

      print(
        'Đã tạo bookmark thành công với status: ${response.statusCode}, data: ${response.data}',
      );

      // Xử lý khi API trả về 201 với cấu trúc {data: {bookmark_id: 57}}
      if (response.statusCode == 201) {
        if (response.data == null) {
          print('API trả về 201 nhưng không có data, tạo model mặc định');
          return BookmarkModel(
            id: DateTime.now().millisecondsSinceEpoch,
            courseId: courseId,
            userUid: userUid,
            createdAt: DateTime.now(),
          );
        }

        // Nếu API trả về cấu trúc {data: {bookmark_id: xxx}}
        if (response.data is Map && response.data['data'] is Map) {
          final responseData = response.data['data'] as Map<String, dynamic>;
          print('Xử lý dữ liệu response: $responseData');

          // Tạo model với bookmark_id từ API
          if (responseData.containsKey('bookmark_id')) {
            return BookmarkModel(
              id: responseData['bookmark_id'] as int,
              courseId: courseId,
              userUid: userUid,
              createdAt: DateTime.now(),
            );
          }
        }
      }

      // Nếu API trả về cấu trúc khác, sử dụng phương thức mặc định
      if (response.data != null && response.data['data'] != null) {
        return BookmarkModel.fromJson(response.data['data']);
      }

      // Fallback: Tạo model mặc định nếu không thể parse dữ liệu
      print('Không thể parse dữ liệu từ API, tạo model mặc định');
      return BookmarkModel(
        id: DateTime.now().millisecondsSinceEpoch,
        courseId: courseId,
        userUid: userUid,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Lỗi khi tạo bookmark: $e');
      if (e is Error) {
        print('Stack trace: ${e.stackTrace}');
      }
      rethrow;
    }
  }

  Future<bool> deleteBookmark({
    required int bookmarkId,
    required String userUid,
  }) async {
    try {
      final data = {'bookmarkId': bookmarkId, 'userUid': userUid};

      print('Đang gửi request xóa bookmark với body: $data');
      final response = await delete(
        ApiConfig.deleteBookmark,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 204,
        ),
      );

      print('Đã xóa bookmark với status: ${response.statusCode}');
      // 204 là No Content, thường dùng cho xóa thành công
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Lỗi khi xóa bookmark: $e');
      if (e is Error) {
        print('Stack trace: ${e.stackTrace}');
      }
      rethrow;
    }
  }
}
