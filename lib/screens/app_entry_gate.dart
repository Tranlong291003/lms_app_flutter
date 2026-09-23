import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/bottomNavigationBar.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/Introduction/intro_screen.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/cubit/auth_state.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/splash_screen.dart';

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

  /// Đã xem intro chưa.
  ///
  /// Trước đây hàm này đọc khoá `'isIntroViewed'` trong khi `IntroCubit` (thứ
  /// thực sự ghi trạng thái) dùng khoá `'intro_seen'`. Hai khoá cho cùng một
  /// việc nên dù người dùng đã bấm "Bỏ qua"/"Bắt đầu", lần mở sau intro vẫn
  /// hiện lại. Giờ đọc qua chính `IntroCubit` để chỉ còn một nguồn sự thật.
  Future<bool> _hasSeenIntro() async {
    await context.read<IntroCubit>().checkIntroStatus();
    if (!mounted) return true;
    return context.read<IntroCubit>().state is IntroViewed;
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
