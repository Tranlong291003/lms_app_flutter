import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/Introduction/Intro_screen.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/home_screen.dart'; // Import HomeScreen

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return BlocBuilder<IntroCubit, IntroState>(
          builder: (context, introState) {
            // Kiểm tra trạng thái của intro, nếu đã xem intro thì chuyển đến HomeScreen
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Custom Light/Dark Theme Demo',
              theme: AppTheme.lightTheme, // Sử dụng lightTheme từ AppTheme
              darkTheme: AppTheme.darkTheme, // Sử dụng darkTheme từ AppTheme
              themeMode: themeState.themeMode, // Lấy từ ThemeBloc
              home:
                  introState is IntroViewed
                      ? const HomeScreen()
                      : const IntroScreen(),
            );
          },
        );
      },
    );
  }
}
