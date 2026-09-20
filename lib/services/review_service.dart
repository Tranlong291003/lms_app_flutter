import 'package:dio/dio.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/models/reivew_model.dart';
import 'package:lms/services/base_service.dart';

class ReviewService extends BaseService {
  ReviewService({super.token});

  /// `GET /api/reviews/course/:courseId` → `{ data: [{ review_id, ... }] }`
  Future<List<Review>> getCourseReviews(int courseId) async {
    try {
      final response = await get(ApiConfig.getCourseReviews(courseId));

      if (response.data is Map && response.data['data'] is List) {
        return (response.data['data'] as List)
            .map(
              (json) => Review.fromJson(Map<String, dynamic>.from(json as Map)),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Không thể tải đánh giá: ${extractApiError(e)}');
    }
  }

  /// `POST /api/reviews/create` → `201 { data: { review_id } }`.
  /// `user_uid` phải trùng với uid trong token.
  Future<void> submitReview({
    required int courseId,
    required String userId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await post(
        ApiConfig.createReview,
        data: {
          'course_id': courseId,
          'user_uid': userId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Gửi đánh giá thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Bạn đã đánh giá khóa học này rồi');
      }
      throw Exception('Gửi đánh giá thất bại: ${extractApiError(e)}');
    }
  }

  Future<void> updateReview({
    required int reviewId,
    required String userUid,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await put(
        ApiConfig.updateReview(reviewId),
        data: {'user_uid': userUid, 'rating': rating, 'comment': comment},
      );

      if (response.statusCode != 200) {
        throw Exception('Cập nhật đánh giá thất bại');
      }
    } on DioException catch (e) {
      throw Exception('Cập nhật đánh giá thất bại: ${extractApiError(e)}');
    }
  }

  Future<void> deleteReview({
    required int reviewId,
    required String userUid,
  }) async {
    try {
      final response = await delete(
        ApiConfig.deleteReview(reviewId),
        data: {'user_uid': userUid},
      );

      if (response.statusCode != 200) {
        throw Exception('Xóa đánh giá thất bại');
      }
    } on DioException catch (e) {
      throw Exception('Xóa đánh giá thất bại: ${extractApiError(e)}');
    }
  }
}
