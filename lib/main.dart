// lib/main.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/cubits/admin/admin_user_cubit.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/cubits/lessons/lesson_detail_cubit.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/mentor_request_cubit.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/cubits/question/question_cubit.dart';
import 'package:lms/cubits/reviews/review_cubit.dart';
import 'package:lms/repositories/admin_user_repository.dart';
import 'package:lms/repositories/category_repository.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/repositories/lesson_repository.dart';
import 'package:lms/repositories/mentor_repository.dart';
import 'package:lms/repositories/mentor_request_repository.dart';
import 'package:lms/repositories/notification_repository.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/repositories/review_repository.dart';
import 'package:lms/repositories/user_repository.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/my_app.dart';
import 'package:lms/services/admin_user_service.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/services/category_service.dart';
import 'package:lms/services/course_service.dart';
import 'package:lms/services/lesson_service.dart';
import 'package:lms/services/mentor_request_service.dart';
import 'package:lms/services/mentor_service.dart';
import 'package:lms/services/notification_service.dart';
import 'package:lms/services/question_service.dart';
import 'package:lms/services/review_service.dart';
import 'package:lms/services/user_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<void> requestPermissions() async {
  // Xin quyền thông báo (Android 13+)
  await Permission.notification.request();
  // Xin quyền truy cập bộ nhớ
  await Permission.storage.request();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ẩn log của AndroidInAppWebView
  if (!kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await Firebase.initializeApp();
  await initializeDateFormatting('vi', null);

  // Yêu cầu quyền ngay khi vào app
  await requestPermissions();

  // 1. Tạo Dio + Services
  final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final userService = UserService();
  final mentorService = MentorService();
  final categoryService = CategoryService();
  final courseService = CourseService();
  final notificationService = NotificationService();
  final adminUserService = AdminUserService();
  final questionService = QuestionService();
  final reviewService = ReviewService();

  // 2. Tạo Repositories
  final userRepository = UserRepository(userService);
  final mentorRepository = MentorRepository(mentorService);
  final categoryRepository = CategoryRepository(categoryService);
  final courseRepository = CourseRepository(courseService);
  final adminUserRepository = AdminUserRepository(adminUserService);
  final questionRepository = QuestionRepository(questionService);
  final reviewRepository = ReviewRepository();
  final notificationRepository = NotificationRepository(
    notificationService: notificationService,
  );

  // 3. Các Cubit/Bloc không phụ thuộc vào BuildContext
  final themeBloc = ThemeBloc()..add(ThemeStarted());
  final introCubit = IntroCubit();
  final authCubit = AuthCubit(
    AuthService(FirebaseAuth.instance, FirebaseMessaging.instance),
  );
  final userBloc = UserBloc(userRepository);
  final mentorBloc = MentorsBloc(mentorRepository);
  final mentorDetailBloc = MentorDetailBloc(mentorRepository);
  final notificationCubit = NotificationCubit(
    notificationRepository: notificationRepository,
  );
  final adminUserCubit = AdminUserCubit(adminUserRepository);
  final courseCubit = CourseCubit(courseRepository);
  final reviewCubit = ReviewCubit();

  // 4. Khởi động các service cần await trước khi chạy UI
  await notificationService.initialize();
  await introCubit.checkIntroStatus();

  // 1. Tạo instance
  final mentorRequestRepository = MentorRequestRepository(
    MentorRequestService(),
  );
  final mentorRequestCubit = MentorRequestCubit(mentorRequestRepository);

  // 5. Chạy app, bọc MyApp trong RepositoryProvider và BlocProvider
  runApp(
    MultiProvider(
      providers: [
        RepositoryProvider<UserRepository>(create: (_) => userRepository),
        RepositoryProvider<MentorRepository>(create: (_) => mentorRepository),
        RepositoryProvider<CategoryRepository>(
          create: (_) => categoryRepository,
        ),
        RepositoryProvider<CourseRepository>(create: (_) => courseRepository),
        Provider<LessonService>(create: (context) => LessonService()),
        Provider<LessonRepository>(
          create:
              (context) => LessonRepository(
                lessonService: context.read<LessonService>(),
              ),
        ),
        RepositoryProvider<NotificationRepository>(
          create: (_) => notificationRepository,
        ),
        RepositoryProvider<MentorRequestRepository>(
          create: (_) => mentorRequestRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => themeBloc),
          BlocProvider<IntroCubit>(create: (_) => introCubit),
          BlocProvider<AuthCubit>(create: (_) => authCubit),
          BlocProvider<UserBloc>(create: (_) => userBloc),
          BlocProvider<NotificationCubit>(create: (_) => notificationCubit),
          BlocProvider<MentorsBloc>(create: (_) => mentorBloc),
          BlocProvider<MentorDetailBloc>(create: (_) => mentorDetailBloc),
          BlocProvider<CategoryCubit>(
            create: (_) => CategoryCubit(categoryRepository),
          ),
          BlocProvider<CourseCubit>(create: (_) => courseCubit),
          BlocProvider<LessonDetailCubit>(create: (_) => LessonDetailCubit()),
          BlocProvider<AdminUserCubit>(create: (_) => adminUserCubit),
          BlocProvider<QuestionCubit>(
            create: (_) => QuestionCubit(questionRepository),
          ),
          BlocProvider<ReviewCubit>(create: (_) => reviewCubit),
          BlocProvider<LessonsCubit>(
            create:
                (context) =>
                    LessonsCubit(repository: context.read<LessonRepository>()),
          ),
          BlocProvider<MentorRequestCubit>(create: (_) => mentorRequestCubit),
        ],
        child: MyApp(notificationService: notificationService),
      ),
    ),
  );
}
