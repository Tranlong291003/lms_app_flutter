import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import thư viện này để điều chỉnh UI hệ thống
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart'; // Import AppTheme để sử dụng themes
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/Introduction/Intro_screen.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/home_screen.dart';
import 'package:lms/screens/login/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1) ThemeBloc
        BlocProvider<ThemeBloc>(
          create: (context) {
            final themeBloc = ThemeBloc();
            themeBloc.add(
              ThemeStarted(),
            ); // Gọi sự kiện ThemeStarted khi ứng dụng bắt đầu
            return themeBloc;
          },
        ),
        // 2) IntroCubit
        BlocProvider<IntroCubit>(
          create: (context) => IntroCubit()..checkIntroStatus(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Thiết lập màu thanh điều hướng khi theme thay đổi
          _setSystemNavigationBarColor(themeState.themeMode);

          return BlocBuilder<IntroCubit, IntroState>(
            builder: (context, introState) {
              return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    // Nếu người dùng đã đăng nhập, chuyển đến HomeScreen
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'Custom Light/Dark Theme Demo',
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      home: HomeScreen(customToken: 'your_custom_token_here'),
                    );
                  }

                  // Kiểm tra trạng thái đã xem Intro hay chưa
                  if (introState is IntroViewed) {
                    // Nếu đã xem intro, điều hướng đến LoginScreen
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'Custom Light/Dark Theme Demo',
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      home: const LoginScreen(),
                    );
                  } else {
                    // Nếu chưa xem intro, điều hướng đến IntroScreen
                    return MaterialApp(
                      debugShowCheckedModeBanner: false,
                      title: 'Custom Light/Dark Theme Demo',
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      home: const IntroScreen(),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  // Hàm thay đổi màu thanh điều hướng hệ thống
  void _setSystemNavigationBarColor(ThemeMode themeMode) {
    // Đặt màu sắc của thanh điều hướng hệ thống (navigation bar)
    if (themeMode == ThemeMode.dark) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
    }
  }
}
