// lib/main.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/blocs/cubit/category/category_cubit.dart';
import 'package:lms/blocs/cubit/notification/notification_cubit.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/repository/category_repository.dart';
import 'package:lms/repository/mentor_repository.dart';
import 'package:lms/repository/user_repository.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/my_app.dart';
import 'package:lms/services/category_service.dart';
import 'package:lms/services/mentor_service.dart';
import 'package:lms/services/notification_service.dart';
import 'package:lms/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('vi', null);

  // 1. Tạo Dio + Services
  final dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));
  final userService = UserService(dio);
  final mentorService = MentorService(dio);
  final categoryService = CategoryService(dio);
  final notificationService = NotificationService();

  // 2. Tạo Repositories
  final userRepository = UserRepository(userService);
  final mentorRepository = MentorRepository(mentorService);
  final categoryRepository = CategoryRepository(categoryService);

  // 3. Các Cubit/Bloc không phụ thuộc vào BuildContext
  final themeBloc = ThemeBloc()..add(ThemeStarted());
  final introCubit = IntroCubit();
  final authCubit = AuthCubit(FirebaseAuth.instance, dio);
  final userBloc = UserBloc(userRepository);
  final mentorBloc = MentorsBloc(mentorRepository);
  final notifCubit = NotificationCubit(notificationService);

  // 4. Khởi động các service cần await trước khi chạy UI
  await notificationService.initialize();
  await introCubit.checkIntroStatus();

  // 5. Chạy app, bọc MyApp trong RepositoryProvider và BlocProvider
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(create: (_) => userRepository),
        RepositoryProvider<MentorRepository>(create: (_) => mentorRepository),
        RepositoryProvider<CategoryRepository>(
          create: (_) => categoryRepository,
        ),
        // ... nếu còn repo khác
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (_) => themeBloc),
          BlocProvider<IntroCubit>(create: (_) => introCubit),
          BlocProvider<AuthCubit>(create: (_) => authCubit),
          BlocProvider<UserBloc>(create: (_) => userBloc),
          BlocProvider<NotificationCubit>(create: (_) => notifCubit),
          BlocProvider<MentorsBloc>(create: (_) => mentorBloc),

          BlocProvider<CategoryCubit>(
            create:
                (context) =>
                    CategoryCubit(context.read<CategoryRepository>())
                      ..loadCategories(),
          ),
        ],
        child: MyApp(notificationService: notificationService),
      ),
    ),
  );
}
