import 'package:lms/models/bookmark_model.dart';
import 'package:lms/repository/base_repository.dart';
import 'package:lms/services/bookmark_service.dart';

class BookmarkRepository extends BaseRepository<BookmarkService> {
  BookmarkRepository(super.service);

  Future<List<BookmarkModel>> getBookmarksByUser(String userUid) async {
    try {
      return await service.getBookmarksByUser(userUid);
    } catch (e) {
      print('Lỗi Repository khi lấy danh sách bookmark: $e');
      rethrow;
    }
  }

  Future<BookmarkModel> createBookmark({
    required int courseId,
    required String userUid,
  }) async {
    try {
      final result = await service.createBookmark(
        courseId: courseId,
        userUid: userUid,
      );
      print(
        'Repository: Bookmark đã được tạo thành công cho khóa học $courseId',
      );
      return result;
    } catch (e) {
      print('Lỗi Repository khi tạo bookmark: $e');
      rethrow;
    }
  }

  Future<bool> deleteBookmark({
    required int bookmarkId,
    required String userUid,
  }) async {
    try {
      final result = await service.deleteBookmark(
        bookmarkId: bookmarkId,
        userUid: userUid,
      );
      if (result) {
        print('Repository: Bookmark $bookmarkId đã được xóa thành công');
      } else {
        print('Repository: Không thể xóa bookmark $bookmarkId');
      }
      return result;
    } catch (e) {
      print('Lỗi Repository khi xóa bookmark: $e');
      rethrow;
    }
  }
}
