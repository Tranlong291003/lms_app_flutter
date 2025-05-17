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
}
