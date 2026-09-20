import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/bottomNavigationBar.dart';
import 'package:lms/screens/Introduction/intro_screen.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/cubit/auth_state.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cổng vào app: quyết định hiển thị Intro / Login / Home.
///
/// Phiên đăng nhập được khôi phục từ token đã lưu bằng cách gọi
/// `AuthCubit.checkAuthStatus()` → `GET /api/auth/me`. 200 → vào app với đúng
/// role hiện tại trong DB; hết phiên → về màn đăng nhập.
class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  @override
  void initState() {
    super.initState();
    // Gọi sau frame đầu để `context.read` chắc chắn đã có provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().checkAuthStatus();
    });
  }

  Future<bool> _hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isIntroViewed') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthCubit>().state.status;

    return FutureBuilder<bool>(
      future: _hasSeenIntro(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SplashScreen();
        }
        // Luôn xem introduction trước khi vào app.
        if (snapshot.data != true) {
          return const IntroScreen();
        }

        switch (status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            // Đang khôi phục phiên.
            return const SplashScreen();
          case AuthStatus.authenticated:
            return const BottomNavigationBarExample();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}
