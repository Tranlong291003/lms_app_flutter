import 'package:flutter/material.dart';
import 'package:lms/screens/bookmark/bookmark_screen.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/forgotpassword/forgotpassword_screen.dart';
import 'package:lms/screens/listCourse/listCourse_screen.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/notification/notification_screen.dart';
import 'package:lms/screens/profile/editprofile_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';
import 'package:lms/screens/quiz/quiz_detail_screen.dart';
import 'package:lms/screens/quiz/quiz_questions_screen.dart';
import 'package:lms/screens/quiz/quiz_screen.dart';
import 'package:lms/screens/signup/signup_screen.dart';
import 'package:lms/screens/listMentor/listMentor_screen.dart';

import '../apps/utils/bottomNavigationBar.dart';
import '../screens/Introduction/intro_screen.dart';

class AppRouter {
  // Route names
  static const String home = '/';
  static const String login = '/login';
  static const String intro = '/intro';
  static const String loginWithPassword = '/loginwithpassword';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotpassword';
  static const String listMentor = '/listmentor';
  static const String listCourse = '/listcourse';
  static const String notification = '/notification';
  static const String bookmark = '/bookmark';
  static const String profile = '/profile';
  static const String editProfile = '/editprofile';
  static const String quiz = '/quiz';
  static const String quizDetail = '/quizdetail';
  static const String quizQuestions = '/quiz/questions';
  static const String courseDetail = '/courseDetail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case home:
        page = BottomNavigationBarExample();
        break;
      case login:
        page = const LoginScreen();
        break;
      case intro:
        page = const IntroScreen();
        break;
      case loginWithPassword:
        page = LoginWithPasswordScreen();
        break;
      case signup:
        page = SignUpScreen();
        break;
      case forgotPassword:
        page = ForgotpasswordScreen();
        break;
      case listMentor:
        page = ListMentorScreen();
        break;
      case listCourse:
        page = ListCoursescreen();
        break;
      case notification:
        page = NotificationScreen();
        break;
      case bookmark:
        page = BookmarkScreen();
        break;
      case profile:
        page = ProfileScreen();
        break;
      case editProfile:
        page = EditProfileScreen();
        break;
      case quiz:
        page = const QuizScreen();
        break;
      case quizDetail:
        page = const QuizDetailScreen();
        break;
      case quizQuestions:
        page = const QuizQuestionsScreen();
        break;
      case courseDetail:
        page = const CourseDetailScreen();
        break;
      default:
        page = const Scaffold(
          body: Center(child: Text('Không tìm thấy trang')),
        );
    }

    return _buildAnimatedRoute(page, settings);
  }

  /// Helper để tạo PageRoute với hiệu ứng slide + fade.
  static PageRouteBuilder _buildAnimatedRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // slide từ phải sang
        final slideAnim = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        // đồng thời fade-in
        final fadeAnim = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(opacity: fadeAnim, child: child),
        );
      },
    );
  }
}
