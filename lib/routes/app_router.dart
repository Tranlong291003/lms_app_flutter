import 'package:flutter/material.dart';
import 'package:lms/screens/bookmark/bookmark_screen.dart';
import 'package:lms/screens/forgotpassword/forgotpassword_screen.dart';
import 'package:lms/screens/listCourse/listCourse_screen.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/notification/notification_screen.dart';
import 'package:lms/screens/signup/signup_screen.dart';
import 'package:lms/screens/topMentor/listMentor_screen.dart';

import '../apps/utils/BottomNavigationBarExampleApp.dart';
import '../screens/Introduction/intro_screen.dart';
import '../screens/login/login_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => BottomNavigationBarExample());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/intro':
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case '/loginwithpassword':
        return MaterialPageRoute(builder: (_) => LoginWithPasswordScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case '/forgotpassword':
        return MaterialPageRoute(builder: (_) => ForgotpasswordScreen());
      case '/listmentor':
        return MaterialPageRoute(builder: (_) => ListMentorScreen());
      case '/listcourse':
        return MaterialPageRoute(builder: (_) => ListCoursescreen());
      case '/notification':
        return MaterialPageRoute(builder: (_) => NotificationScreen());
      case '/bookmark':
        return MaterialPageRoute(builder: (_) => BookmarkScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) => const Scaffold(
                body: Center(child: Text('Không tìm thấy trang')),
              ),
        );
    }
  }
}
