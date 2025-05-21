import 'package:firebase_auth/firebase_auth.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/reivew_model.dart';
import 'package:lms/services/base_service.dart';

class ReviewService extends BaseService {
  Future<List<Review>> getCourseReviews(int courseId) async {
    try {
      print('Fetching reviews for course: $courseId');
      final response = await get(
        '${ApiConfig.baseUrl}/api/reviews/course/$courseId',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> reviewsData = responseData['data'] ?? [];
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
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
      final response = await post(
        '${ApiConfig.baseUrl}/api/reviews/create',
        data: {
          'course_id': courseId,
          'user_uid': userId,
          'user_name': userName,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to submit review');
      }
    } catch (e) {
      print('Error submitting review: $e');
      rethrow;
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await put(
        '${ApiConfig.baseUrl}/api/reviews/update/$reviewId',
        data: {
          'user_uid': currentUser.uid,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update review');
      }
    } catch (e) {
      print('Error updating review: $e');
      rethrow;
    }
  }

  Future<void> deleteReview({required int reviewId}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final response = await delete(
        '${ApiConfig.baseUrl}/api/reviews/delete/$reviewId',
        data: {'user_uid': currentUser.uid},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete review');
      }
    } catch (e) {
      print('Error deleting review: $e');
      rethrow;
    }
  }
}
