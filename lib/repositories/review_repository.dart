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
    required String userName,
    required int rating,
    required String comment,
  }) async {
    try {
      print('DEBUG ReviewRepository: Submitting review for course $courseId');
      await service.submitReview(
        courseId: courseId,
        userId: userId,
        userName: userName,
        rating: rating,
        comment: comment,
      );
      print('DEBUG ReviewRepository: Review submitted successfully');
    } catch (e) {
      print('ERROR ReviewRepository: Failed to submit review');
      print('ERROR ReviewRepository: $e');
      rethrow;
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      print('DEBUG ReviewRepository: Updating review $reviewId');
      await service.updateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
      print('DEBUG ReviewRepository: Review updated successfully');
    } catch (e) {
      print('ERROR ReviewRepository: Failed to update review');
      print('ERROR ReviewRepository: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      print('DEBUG ReviewRepository: Deleting review $reviewId');
      await service.deleteReview(reviewId: reviewId);
      print('DEBUG ReviewRepository: Review deleted successfully');
    } catch (e) {
      print('ERROR ReviewRepository: Failed to delete review');
      print('ERROR ReviewRepository: $e');
      rethrow;
    }
  }
}
