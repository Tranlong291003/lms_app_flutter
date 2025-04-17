import 'package:dio/dio.dart'; // Thêm Dio để tạo AuthCubit
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  // Khởi tạo các bloc và cubit
  final themeBloc =
      ThemeBloc()
        ..add(ThemeStarted()); // Gọi sự kiện ThemeStarted khi ứng dụng bắt đầu
  final introCubit = IntroCubit(); // Khởi tạo IntroCubit
  final dio = Dio(); // Tạo đối tượng Dio để sử dụng trong AuthCubit
  final authCubit = AuthCubit(FirebaseAuth.instance, dio); // Khởi tạo AuthCubit

  // Kiểm tra trạng thái intro khi mở app
  await introCubit.checkIntroStatus();

  runApp(
    MultiBlocProvider(
      providers: [
        // Cung cấp các Bloc và Cubit cho toàn bộ ứng dụng
        BlocProvider<ThemeBloc>(create: (_) => themeBloc),
        BlocProvider<IntroCubit>(create: (_) => introCubit),
        BlocProvider<AuthCubit>(create: (_) => authCubit), // Cung cấp AuthCubit
      ],
      child: const MyApp(), // Gọi MyApp làm root widget
    ),
  );
}
