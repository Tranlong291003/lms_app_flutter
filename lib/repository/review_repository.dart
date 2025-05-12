import 'package:lms/models/reivew_model.dart';
import 'package:lms/repository/base_repository.dart';
import 'package:lms/services/review_service.dart';

class ReviewRepository extends BaseRepository<ReviewService> {
  ReviewRepository() : super(ReviewService());

  Future<List<Review>> getCourseReviews(int courseId) async {
    try {
      final reviews = await service.getCourseReviews(courseId);
      print(
        'DEBUG ReviewRepository: Converting ${reviews.length} reviews to model',
      );
      return reviews.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      print(
        'ERROR ReviewRepository: Failed to get reviews for course $courseId',
      );
      print('ERROR ReviewRepository: $e');
      rethrow;
    }
  }
}
