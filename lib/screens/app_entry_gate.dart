import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/utils/bottomNavigationBar.dart';
import 'package:lms/screens/Introduction/intro_screen.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppEntryGate extends StatelessWidget {
  const AppEntryGate({super.key});

  Future<Widget> _getEntryWidget() async {
    final prefs = await SharedPreferences.getInstance();
    final isIntroViewed = prefs.getBool('isIntroViewed') ?? false;

    // Luôn kiểm tra introduction trước
    if (!isIntroViewed) {
      return const IntroScreen();
    }

    // Sau khi đã xem introduction, mới kiểm tra login
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return BottomNavigationBarExample();
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getEntryWidget(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SplashScreen();
        }
        return snapshot.data!;
      },
    );
  }
}
