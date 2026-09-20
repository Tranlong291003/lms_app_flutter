import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/reviews/review_state.dart';
import 'package:lms/repositories/review_repository.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;

  ReviewCubit({ReviewRepository? repository})
    : _repository = repository ?? ReviewRepository(),
      super(const ReviewInitial());

  Future<void> loadCourseReviews(int courseId) async {
    try {
      emit(const ReviewLoading());
      print('DEBUG ReviewCubit: Loading reviews for course $courseId');
      final reviews = await _repository.getCourseReviews(courseId);
      print('DEBUG ReviewCubit: Loaded ${reviews.length} reviews');
      emit(ReviewLoaded(reviews));
    } catch (e) {
      print('ERROR ReviewCubit: Failed to load reviews');
      print('ERROR ReviewCubit: $e');
      emit(ReviewError(e.toString()));
    }
  }

  void refreshReviews(int courseId) {
    loadCourseReviews(courseId);
  }

  Future<void> submitReview({
    required int courseId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      emit(const ReviewLoading());
      await _repository.submitReview(
        courseId: courseId,
        userId: userId,
        rating: rating,
        comment: comment,
      );
      // Refresh reviews after submitting
      await loadCourseReviews(courseId);
    } catch (e) {
      print('ERROR ReviewCubit: Failed to submit review');
      print('ERROR ReviewCubit: $e');
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required int courseId,
    required String userUid,
    required int rating,
    required String comment,
  }) async {
    try {
      emit(const ReviewLoading());
      await _repository.updateReview(
        reviewId: reviewId,
        userUid: userUid,
        rating: rating,
        comment: comment,
      );
      // Refresh reviews after updating
      await loadCourseReviews(courseId);
    } catch (e) {
      print('ERROR ReviewCubit: Failed to update review');
      print('ERROR ReviewCubit: $e');
      emit(ReviewError(e.toString()));
    }
  }

  Future<void> deleteReview({
    required int reviewId,
    required int courseId,
    required String userUid,
  }) async {
    try {
      emit(const ReviewLoading());
      await _repository.deleteReview(reviewId: reviewId, userUid: userUid);
      // Refresh reviews after deleting
      await loadCourseReviews(courseId);
    } catch (e) {
      print('ERROR ReviewCubit: Failed to delete review');
      print('ERROR ReviewCubit: $e');
      emit(ReviewError(e.toString()));
    }
  }
}
