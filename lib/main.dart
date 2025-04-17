import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/my_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final themeBloc = ThemeBloc()..add(ThemeStarted());
  final introCubit = IntroCubit();

  // Khởi tạo IntroCubit và kiểm tra trạng thái intro khi mở app
  await introCubit.checkIntroStatus();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(create: (_) => themeBloc),
        BlocProvider<IntroCubit>(
          create: (_) => introCubit,
        ), // Cung cấp IntroCubit
      ],
      child: const MyApp(),
    ),
  );
}
