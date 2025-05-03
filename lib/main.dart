import 'package:dio/dio.dart'; // Thêm Dio để tạo AuthCubit
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/blocs/cubit/notification_cubit.dart'; // Import NotificationCubit
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/repository/user_repository.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/my_app.dart';
import 'package:lms/services/notification_service.dart'; // Import NotificationService
import 'package:lms/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  // Khởi tạo DateFormat cho ngôn ngữ Việt
  await initializeDateFormatting('vi', null);

  // Khởi tạo các service và repository
  final notificationService =
      NotificationService(); // Khởi tạo NotificationService
  final notificationCubit = NotificationCubit(
    notificationService,
  ); // Khởi tạo NotificationCubit
  final dio = Dio();
  final userService = UserService(dio);
  final userRepository = UserRepository(userService);

  // Khởi tạo UserBloc và AuthCubit
  final userBloc = UserBloc(userRepository);
  final authCubit = AuthCubit(FirebaseAuth.instance, dio);

  // Khởi tạo ThemeBloc
  final themeBloc = ThemeBloc()..add(ThemeStarted());

  // Khởi tạo IntroCubit
  final introCubit = IntroCubit();

  // Khởi tạo NotificationService
  await notificationService.initialize();

  // Kiểm tra trạng thái intro khi mở app
  await introCubit.checkIntroStatus();

  // Chạy ứng dụng Flutter và cung cấp các Bloc và Cubit
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => themeBloc), // Cung cấp ThemeBloc
        BlocProvider<IntroCubit>(
          create: (_) => introCubit,
        ), // Cung cấp IntroCubit
        BlocProvider<AuthCubit>(create: (_) => authCubit), // Cung cấp AuthCubit
        BlocProvider<UserBloc>(create: (_) => userBloc), // Cung cấp UserBloc
        BlocProvider<NotificationCubit>(
          create: (_) => notificationCubit,
        ), // Cung cấp NotificationCubit
      ],
      child: MyApp(
        notificationService: notificationService,
      ), // Gọi MyApp làm root widget
    ),
  );
}
