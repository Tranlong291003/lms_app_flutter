import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/loading_animation_widget.dart';
import 'package:lms/cubits/quiz/quiz_cubit.dart';
import 'package:lms/cubits/quiz/quiz_state.dart';
import 'package:lms/models/quiz/quiz_course_model.dart';
import 'package:lms/models/quiz/quiz_model.dart';
import 'package:lms/repositories/quiz_repository.dart';
import 'package:lms/screens/quiz/user_quiz_results_screen.dart';
import 'package:lms/services/quiz_service.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late QuizCubit _quizCubit;
  String? _userUid;
  bool _isInitialized = false;

  // Set để lưu trạng thái mở rộng của các khóa học
  final Set<int> _expandedEnrolledCourses = {};
  final Set<int> _expandedNotEnrolledCourses = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Khởi tạo QuizCubit
    final quizService = QuizService();
    final quizRepository = QuizRepository(quizService);
    _quizCubit = QuizCubit(quizRepository);

    _initUser();
  }

  Future<void> _initUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userUid = user.uid;
        _isInitialized = true;
      });

      // Gọi API lấy dữ liệu bài kiểm tra
      await _loadQuizzes();
    } else {
      print('QuizListScreen: Người dùng chưa đăng nhập');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadQuizzes() async {
    if (_userUid != null) {
      await _quizCubit.getQuizzesByUser(_userUid!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quizCubit.close();
    super.dispose();
  }

  // Hàm xử lý khi nhấn nút mở rộng/thu gọn
  void _toggleExpansion(int courseId, bool isEnrolled) {
    setState(() {
      if (isEnrolled) {
        if (_expandedEnrolledCourses.contains(courseId)) {
          _expandedEnrolledCourses.remove(courseId);
        } else {
          _expandedEnrolledCourses.add(courseId);
        }
      } else {
        if (_expandedNotEnrolledCourses.contains(courseId)) {
          _expandedNotEnrolledCourses.remove(courseId);
        } else {
          _expandedNotEnrolledCourses.add(courseId);
        }
      }
    });
  }

  // Kiểm tra khóa học có đang mở rộng không
  bool _isExpanded(int courseId, bool isEnrolled) {
    return isEnrolled
        ? _expandedEnrolledCourses.contains(courseId)
        : _expandedNotEnrolledCourses.contains(courseId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    if (_userUid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bài kiểm tra')),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem bài kiểm tra'),
        ),
      );
    }

    return BlocProvider.value(
      value: _quizCubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bài kiểm tra'),
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.7),
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
              insets: EdgeInsets.zero,
            ),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: 'Tất cả bài kiểm tra'),
              Tab(text: 'Bài đã làm'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await _quizCubit.refreshQuizzes(_userUid!);
              },
            ),
          ],
        ),
        body: BlocBuilder<QuizCubit, QuizState>(
          builder: (context, state) {
            if (state.status == QuizStatus.loading &&
                state.enrolledCourses.isEmpty) {
              return const Center(child: LoadingIndicator());
            }

            if (state.status == QuizStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã xảy ra lỗi: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadQuizzes,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Tất cả bài kiểm tra
                RefreshIndicator(
                  onRefresh: () => _quizCubit.refreshQuizzes(_userUid!),
                  child: _buildEnrolledQuizzes(state.enrolledCourses),
                ),
                // Tab 2: Bài đã làm
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: UserQuizResultsScreen(userUid: _userUid!),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnrolledQuizzes(List<QuizCourseModel> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Text(
          'Bạn chưa có bài kiểm tra nào trong các khóa học đã đăng ký',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return _buildCourseSection(course, true);
      },
    );
  }

  Widget _buildCourseSection(QuizCourseModel course, bool isEnrolled) {
    final isExpanded = _isExpanded(course.courseId, isEnrolled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => _toggleExpansion(course.courseId, isEnrolled),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color:
                  isEnrolled
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    course.courseTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isEnrolled
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${course.quizzes.length} bài kiểm tra',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isEnrolled
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color:
                      isEnrolled
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ...course.quizzes.map((quiz) => _buildQuizItem(quiz, isEnrolled)),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildQuizItem(QuizModel quiz, bool isEnrolled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isEnrolled
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isEnrolled ? () => _navigateToQuizDetail(quiz) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getQuizTypeColor(quiz.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quiz.displayType,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thời gian: ${quiz.timeLimit} phút',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    if (!isEnrolled)
                      const Icon(Icons.lock, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  quiz.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quiz.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    quiz.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày tạo: ${quiz.formattedCreatedAt}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Số lần làm: ${quiz.attemptLimit}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getQuizTypeColor(String type) {
    switch (type) {
      case 'trac_nghiem':
        return Colors.blue;
      case 'tu_luan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _navigateToQuizDetail(QuizModel quiz) {
    // Xác định màu sắc dựa trên loại quiz
    final Color quizColor = _getQuizTypeColor(quiz.type);

    // Xác định biểu tượng dựa trên loại quiz
    final IconData quizIcon =
        quiz.type == 'trac_nghiem'
            ? Icons.check_circle_outline
            : Icons.edit_note;

    // Chuyển sang màn hình chi tiết quiz
    Navigator.pushNamed(
      context,
      AppRouter.quizDetail,
      arguments: {
        'quizId': quiz.quizId,
        'title': quiz.title,
        'description': quiz.description,
        'duration': quiz.timeLimit,
        'questionCount': quiz.durationType.questionCount,
        'difficulty': quiz.displayType,
        'color': quizColor,
        'icon': quizIcon,
        'quizInfo': quiz,
      },
    );
  }
}
