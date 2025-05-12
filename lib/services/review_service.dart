import 'package:lms/services/base_service.dart';

class ReviewService extends BaseService {
  ReviewService() : super();

  Future<List<dynamic>> getCourseReviews(int courseId) async {
    try {
      final response = await get('/api/reviews/courses/$courseId');
      print('DEBUG ReviewService: Fetched reviews for course $courseId');
      return response.data['data'] ?? [];
    } catch (e) {
      print(
        'ERROR ReviewService: Failed to fetch reviews for course $courseId',
      );
      print('ERROR ReviewService: $e');
      rethrow;
    }
  }
}
