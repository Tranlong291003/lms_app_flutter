import 'package:lms/models/bookmark_model.dart';

enum BookmarkStatus { initial, loading, loaded, error }

class BookmarkState {
  final BookmarkStatus status;
  final List<BookmarkModel> bookmarks;
  final String errorMessage;
  final bool isBookmarking;
  final bool isDeleting;

  BookmarkState({
    this.status = BookmarkStatus.initial,
    this.bookmarks = const [],
    this.errorMessage = '',
    this.isBookmarking = false,
    this.isDeleting = false,
  });

  BookmarkState copyWith({
    BookmarkStatus? status,
    List<BookmarkModel>? bookmarks,
    String? errorMessage,
    bool? isBookmarking,
    bool? isDeleting,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      errorMessage: errorMessage ?? this.errorMessage,
      isBookmarking: isBookmarking ?? this.isBookmarking,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}
