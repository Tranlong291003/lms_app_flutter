import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to adjust system UI
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart'; // Import AppTheme to use themes
import 'package:lms/apps/utils/route_observer.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/services/notification_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import LoadingAnimationWidget

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            // Thay đổi màu thanh điều hướng hệ thống (navigation bar)
            _setSystemNavigationBarColor(themeState.themeMode);

            return FutureBuilder<User?>(
              future: _getUser(),
              builder: (context, snapshot) {
                // Hiển thị vòng quay loading khi đang chờ
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    backgroundColor: const Color.fromARGB(
                      255,
                      136,
                      173,
                      192,
                    ), // Semi-transparent black background
                    body: Center(
                      child: LoadingAnimationWidget.beat(
                        color: Colors.white,
                        size: 50.0, // Spinner size
                      ),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  // If the user is logged in, navigate to HomeScreen
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Custom Light/Dark Theme Demo',
                    theme: AppTheme.lightTheme.copyWith(
                      textTheme: AppTheme.lightTheme.textTheme.apply(
                        fontFamily: 'Roboto',
                      ),
                    ),
                    darkTheme: AppTheme.darkTheme.copyWith(
                      textTheme: AppTheme.darkTheme.textTheme.apply(
                        fontFamily: 'Roboto',
                      ),
                    ),
                    themeMode: themeState.themeMode,
                    initialRoute: '/',
                    onGenerateRoute: AppRouter.generateRoute,
                    navigatorObservers: [routeObserver],
                  );
                }

                // Handle the case where the user is not logged in
                return BlocBuilder<IntroCubit, IntroState>(
                  builder: (context, introState) {
                    if (introState is IntroViewed) {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'Custom Light/Dark Theme Demo',
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        initialRoute: '/login',
                        onGenerateRoute: AppRouter.generateRoute,
                      );
                    } else {
                      return MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'Custom Light/Dark Theme Demo',
                        theme: AppTheme.lightTheme,
                        darkTheme: AppTheme.darkTheme,
                        initialRoute: '/intro',
                        onGenerateRoute: AppRouter.generateRoute,
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// Hàm thay đổi màu thanh điều hướng hệ thống
Future<void> _setSystemNavigationBarColor(ThemeMode themeMode) async {
  // Simulate async operation
  await Future.delayed(Duration(milliseconds: 100));

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

// Hàm lấy thông tin người dùng (async function)
Future<User?> _getUser() async {
  // Simulate async delay for Firebase Auth check
  await Future.delayed(Duration(milliseconds: 500));
  return FirebaseAuth.instance.currentUser; // Lấy người dùng hiện tại
}
