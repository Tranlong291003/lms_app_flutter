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
import 'package:lms/screens/topMentor/listMentor_screen.dart';

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
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => BottomNavigationBarExample());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case intro:
        return MaterialPageRoute(builder: (_) => const IntroScreen());
      case loginWithPassword:
        return MaterialPageRoute(builder: (_) => LoginWithPasswordScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => SignUpScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => ForgotpasswordScreen());
      case listMentor:
        return MaterialPageRoute(builder: (_) => ListMentorScreen());
      case listCourse:
        return MaterialPageRoute(builder: (_) => ListCoursescreen());
      case notification:
        return MaterialPageRoute(builder: (_) => NotificationScreen());
      case bookmark:
        return MaterialPageRoute(builder: (_) => BookmarkScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      case quiz:
        return MaterialPageRoute(builder: (_) => const QuizScreen());
      case quizDetail:
        return MaterialPageRoute(
          builder: (_) => const QuizDetailScreen(),
          settings: settings, // Pass the arguments
        );
      case quizQuestions:
        return MaterialPageRoute(
          builder: (_) => const QuizQuestionsScreen(),
          settings: settings, // Pass the arguments
        );
      case courseDetail:
        return MaterialPageRoute(builder: (_) => const CourseDetailScreen());
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
