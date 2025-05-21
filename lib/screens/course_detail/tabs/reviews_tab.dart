import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/lessons/lessons_state.dart';
import 'package:lms/cubits/reviews/review_cubit.dart';
import 'package:lms/cubits/reviews/review_state.dart';
import 'package:lms/models/reivew_model.dart';

class ReviewsTab extends StatefulWidget {
  final int courseId;

  const ReviewsTab({super.key, required this.courseId});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  void initState() {
    super.initState();
    // Load reviews when entering the tab
    context.read<ReviewCubit>().loadCourseReviews(widget.courseId);
  }

  Future<bool> _checkCourseCompletion(BuildContext context) async {
    final lessonsState = context.read<LessonsCubit>().state;
    if (lessonsState is! LessonsLoaded) return false;

    final lessons = lessonsState.lessons;
    if (lessons.isEmpty) return false;

    // Check if all lessons are completed
    return lessons.every((lesson) => lesson.isCompleted);
  }

  void _showReviewDialog(
    BuildContext context, {
    Review? review,
    required ReviewCubit reviewCubit,
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final TextEditingController commentController = TextEditingController(
      text: review?.comment ?? '',
    );
    int rating = review?.rating ?? 5;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    review == null ? 'Đánh giá khóa học' : 'Chỉnh sửa đánh giá',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() {
                                rating = index + 1;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Nhận xét của bạn',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (review == null) {
                          reviewCubit.submitReview(
                            courseId: widget.courseId,
                            userId: currentUser.uid,
                            userName: currentUser.displayName ?? 'Người dùng',
                            rating: rating,
                            comment: commentController.text,
                          );
                        } else {
                          reviewCubit.updateReview(
                            reviewId: review.reviewId,
                            courseId: widget.courseId,
                            rating: rating,
                            comment: commentController.text,
                          );
                        }
                        Navigator.pop(context);
                      },
                      child: Text(review == null ? 'Gửi' : 'Cập nhật'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context, {
    required Review review,
    required ReviewCubit reviewCubit,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa đánh giá này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  reviewCubit.deleteReview(
                    reviewId: review.reviewId,
                    courseId: widget.courseId,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is ReviewInitial) {
          return const Center(child: LoadingIndicator());
        }

        if (state is ReviewLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (state is ReviewError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReviewCubit>().loadCourseReviews(
                      widget.courseId,
                    );
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is ReviewLoaded) {
          final reviews = state.reviews;
          final userReview = reviews.firstWhere(
            (review) => review.userUid == currentUser?.uid,
            orElse:
                () => Review(
                  reviewId: -1,
                  courseId: widget.courseId,
                  userUid: '',
                  userName: '',
                  userAvatarUrl: '',
                  rating: 0,
                  comment: '',
                  createdAt: DateTime.now(),
                ),
          );

          return Column(
            children: [
              if (userReview.reviewId == -1)
                FutureBuilder<bool>(
                  future: _checkCourseCompletion(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: LoadingIndicator());
                    }

                    final canReview = snapshot.data ?? false;
                    if (!canReview) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Bạn cần hoàn thành tất cả bài học để đánh giá khóa học này',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _showReviewDialog(
                              context,
                              reviewCubit: context.read<ReviewCubit>(),
                            ),
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Đánh giá khóa học'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    );
                  },
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final isCurrentUserReview =
                        review.userUid == currentUser?.uid;
                    final avatarUrl =
                        review.userAvatarUrl.isNotEmpty
                            ? (review.userAvatarUrl.startsWith('http')
                                ? review.userAvatarUrl
                                : ApiConfig.getImageUrl(review.userAvatarUrl))
                            : 'https://www.gravatar.com/avatar/?d=mp';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.12),
                                  backgroundImage: NetworkImage(avatarUrl),
                                  onBackgroundImageError: (_, __) {},
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          ...List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                          const SizedBox(width: 8),
                                          Text(
                                            review.createdAt.toString().split(
                                              ' ',
                                            )[0],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrentUserReview)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showReviewDialog(
                                          context,
                                          review: review,
                                          reviewCubit:
                                              context.read<ReviewCubit>(),
                                        );
                                      } else if (value == 'delete') {
                                        _showDeleteConfirmation(
                                          context,
                                          review: review,
                                          reviewCubit:
                                              context.read<ReviewCubit>(),
                                        );
                                      }
                                    },
                                    itemBuilder:
                                        (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 20),
                                                SizedBox(width: 8),
                                                Text('Chỉnh sửa'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Xóa',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                  ),
                              ],
                            ),
                            if (review.comment.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                review.comment,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  static const String defaultAvatarAsset = 'assets/images/default_avatar.png';
  static const String defaultAvatarNet =
      'https://www.gravatar.com/avatar/?d=mp';

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl =
        (review.userAvatarUrl.isNotEmpty)
            ? (review.userAvatarUrl.startsWith('http')
                ? review.userAvatarUrl
                : ApiConfig.getImageUrl(review.userAvatarUrl))
            : defaultAvatarNet;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.12),
                  backgroundImage: NetworkImage(avatarUrl),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(review.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    review.rating,
                    (_) => Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
