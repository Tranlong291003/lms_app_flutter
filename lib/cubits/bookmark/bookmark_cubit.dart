import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/bookmark/bookmark_state.dart';
import 'package:lms/models/bookmark_model.dart';
import 'package:lms/repositories/bookmark_repository.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _bookmarkRepository;

  BookmarkCubit(this._bookmarkRepository) : super(BookmarkState());

  Future<void> getBookmarks(String userUid) async {
    try {
      emit(state.copyWith(status: BookmarkStatus.loading));

      print('Đang lấy danh sách bookmark cho user: $userUid');
      final bookmarks = await _bookmarkRepository.getBookmarksByUser(userUid);

      print('Đã nhận được ${bookmarks.length} bookmark');
      emit(state.copyWith(status: BookmarkStatus.loaded, bookmarks: bookmarks));
    } catch (e) {
      print('Lỗi Cubit khi lấy danh sách bookmark: $e');
      emit(
        state.copyWith(
          status: BookmarkStatus.error,
          errorMessage: 'Không thể lấy danh sách bookmark: $e',
        ),
      );
    }
  }

  Future<void> refreshBookmarks(String userUid) async {
    try {
      print('Đang làm mới danh sách bookmark cho user: $userUid');
      final bookmarks = await _bookmarkRepository.getBookmarksByUser(userUid);

      print('Đã làm mới: ${bookmarks.length} bookmark');
      emit(state.copyWith(bookmarks: bookmarks));
    } catch (e) {
      print('Lỗi khi làm mới bookmark: $e');
    }
  }

  Future<BookmarkModel> createBookmark({
    required int courseId,
    required String userUid,
  }) async {
    try {
      emit(state.copyWith(isBookmarking: true));

      print('Đang tạo bookmark cho khóa học ID: $courseId, User: $userUid');
      final newBookmark = await _bookmarkRepository.createBookmark(
        courseId: courseId,
        userUid: userUid,
      );

      print('Đã tạo bookmark thành công với ID: ${newBookmark.id}');

      final updatedBookmarks = List<BookmarkModel>.from(state.bookmarks)
        ..add(newBookmark);

      emit(state.copyWith(bookmarks: updatedBookmarks, isBookmarking: false));
      return newBookmark;
    } catch (e) {
      print('Lỗi Cubit khi tạo bookmark: $e');
      emit(
        state.copyWith(
          isBookmarking: false,
          errorMessage: 'Không thể tạo bookmark: $e',
        ),
      );
      rethrow;
    }
  }

  Future<bool> deleteBookmark({
    required int bookmarkId,
    required String userUid,
  }) async {
    try {
      emit(state.copyWith(isDeleting: true));

      print('Đang xóa bookmark ID: $bookmarkId, User: $userUid');
      final success = await _bookmarkRepository.deleteBookmark(
        bookmarkId: bookmarkId,
        userUid: userUid,
      );

      if (success) {
        print('Đã xóa bookmark thành công');
        final updatedBookmarks =
            state.bookmarks
                .where((bookmark) => bookmark.id != bookmarkId)
                .toList();

        emit(state.copyWith(bookmarks: updatedBookmarks, isDeleting: false));
        return true;
      } else {
        throw Exception('Không thể xóa bookmark');
      }
    } catch (e) {
      print('Lỗi Cubit khi xóa bookmark: $e');
      emit(
        state.copyWith(
          isDeleting: false,
          errorMessage: 'Không thể xóa bookmark: $e',
        ),
      );
      return false;
    }
  }

  bool isBookmarked(int courseId) {
    final result = state.bookmarks.any(
      (bookmark) => bookmark.courseId == courseId,
    );
    print('isBookmarked kiểm tra courseId $courseId: $result');
    print('Số lượng bookmark hiện tại: ${state.bookmarks.length}');
    if (result) {
      print('Khóa học $courseId đã được bookmark');
    } else {
      print('Khóa học $courseId chưa được bookmark');
    }
    return result;
  }

  BookmarkModel? getBookmarkByCourseId(int courseId) {
    try {
      final bookmark = state.bookmarks.firstWhere(
        (bookmark) => bookmark.courseId == courseId,
      );
      print('Tìm thấy bookmark cho khóa học $courseId: ${bookmark.id}');
      return bookmark;
    } catch (_) {
      print('Không tìm thấy bookmark cho khóa học $courseId');
      return null;
    }
  }
}
