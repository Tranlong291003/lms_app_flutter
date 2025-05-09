import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import to adjust system UI
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/config/app_theme.dart'; // Import AppTheme to use themes
import 'package:lms/apps/utils/route_observer.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/app_entry_gate.dart';
import 'package:lms/services/notification_service.dart';

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        _setSystemNavigationBarColor(themeState.themeMode);
        final themeData =
            themeState.themeMode == ThemeMode.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme;
        return AnimatedTheme(
          data: themeData,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const AppEntryGate(),
            onGenerateRoute: AppRouter.generateRoute,
            navigatorObservers: [routeObserver],
          ),
        );
      },
    );
  }
}

// Hàm thay đổi màu thanh điều hướng hệ thống
Future<void> _setSystemNavigationBarColor(ThemeMode themeMode) async {
  await Future.delayed(const Duration(milliseconds: 100));
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
