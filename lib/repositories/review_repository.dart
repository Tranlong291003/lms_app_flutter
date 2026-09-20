import 'package:lms/models/reivew_model.dart';
import 'package:lms/repositories/base_repository.dart';
import 'package:lms/services/review_service.dart';

class ReviewRepository extends BaseRepository<ReviewService> {
  ReviewRepository() : super(ReviewService());

  Future<List<Review>> getCourseReviews(int courseId) async {
    try {
      final reviews = await service.getCourseReviews(courseId);
      print(
        'DEBUG ReviewRepository: Converting ${reviews.length} reviews to model',
      );
      return reviews;
    } catch (e) {
      print(
        'ERROR ReviewRepository: Failed to get reviews for course $courseId',
      );
      print('ERROR ReviewRepository: $e');
      rethrow;
    }
  }

  Future<void> submitReview({
    required int courseId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      await service.submitReview(
        courseId: courseId,
        userId: userId,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      print('ERROR ReviewRepository: Failed to submit review: $e');
      rethrow;
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required String userUid,
    required int rating,
    required String comment,
  }) async {
    try {
      await service.updateReview(
        reviewId: reviewId,
        userUid: userUid,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      print('ERROR ReviewRepository: Failed to update review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview({
    required int reviewId,
    required String userUid,
  }) async {
    try {
      await service.deleteReview(reviewId: reviewId, userUid: userUid);
    } catch (e) {
      print('ERROR ReviewRepository: Failed to delete review: $e');
      rethrow;
    }
  }
}
