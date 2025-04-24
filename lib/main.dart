import 'package:dio/dio.dart'; // Thêm Dio để tạo AuthCubit
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/repository/user_repository.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/my_app.dart';
import 'package:lms/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase
  await initializeDateFormatting(
    'vi',
    null,
  ); // Đảm bảo định dạng ngày tháng chuẩn việt

  // Khởi tạo các bloc và cubit
  final themeBloc =
      ThemeBloc()
        ..add(ThemeStarted()); // Gọi sự kiện ThemeStarted khi ứng dụng bắt đầu
  final introCubit = IntroCubit(); // Khởi tạo IntroCubit

  // Khởi tạo Dio và các service
  final dio = Dio();
  final userService = UserService(dio);
  final userRepository = UserRepository(userService);
  final userBloc = UserBloc(userRepository);

  // Khởi tạo AuthCubit
  final authCubit = AuthCubit(FirebaseAuth.instance, dio); // Khởi tạo AuthCubit

  // Kiểm tra trạng thái intro khi mở app
  await introCubit.checkIntroStatus();

  // Cung cấp BlocProvider cho các bloc và cubit
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => themeBloc),
        BlocProvider<IntroCubit>(create: (_) => introCubit),
        BlocProvider<AuthCubit>(create: (_) => authCubit), // Cung cấp AuthCubit
        BlocProvider<UserBloc>(create: (_) => userBloc), // Cung cấp UserBloc
      ],
      child: const MyApp(), // Gọi MyApp làm root widget
    ),
  );
}
