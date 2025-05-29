import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/screens/Introduction/intro_screen.dart';
import 'package:lms/screens/app_entry_gate.dart';
import 'package:lms/screens/bookmark/bookmark_screen.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/course_detail/lesson_detail_screen.dart';
import 'package:lms/screens/dashboard/admin/admin_dashboard_screen.dart';
import 'package:lms/screens/dashboard/admin/category_management_screen.dart';
import 'package:lms/screens/dashboard/admin/course_management_admin_screen.dart';
import 'package:lms/screens/dashboard/admin/user_management_screen.dart';
import 'package:lms/screens/dashboard/mentor/course_management_screen.dart';
import 'package:lms/screens/forgotpassword/forgotpassword_screen.dart';
import 'package:lms/screens/help/help_screen.dart';
import 'package:lms/screens/invite/invite_screen.dart';
import 'package:lms/screens/language/language_screen.dart';
import 'package:lms/screens/listCourse/listCourse_screen.dart';
import 'package:lms/screens/listMentor/listMentor_screen.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/notification/notification_setting_screen.dart';
import 'package:lms/screens/payment/payment_screen.dart';
import 'package:lms/screens/privacy/privacy_screen.dart';
import 'package:lms/screens/profile/editprofile_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';
import 'package:lms/screens/quiz/quiz_detail_screen.dart';
import 'package:lms/screens/quiz/quiz_list_screen.dart';
import 'package:lms/screens/quiz/quiz_questions_screen.dart';
import 'package:lms/screens/quiz/quiz_result_detail_screen.dart';
import 'package:lms/screens/quiz/quiz_screen.dart';
import 'package:lms/screens/security/change_password_screen.dart';
import 'package:lms/screens/security/security_screen.dart';
import 'package:lms/screens/signup/signup_screen.dart';
import 'package:lms/screens/user_detail_screen.dart';

import '../utils/bottomNavigationBar.dart';

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
  static const String notificationSetting = '/notificationSetting';
  static const String bookmark = '/bookmark';
  static const String profile = '/profile';
  static const String editProfile = '/editprofile';
  static const String quiz = '/quiz';
  static const String quizList = '/quiz-list';
  static const String quizDetail = '/quizdetail';
  static const String quizQuestions = '/quiz/questions';
  static const String courseDetail = '/courseDetail';
  static const String mentorDetail = '/mentordetail';
  static const String payment = '/payment';
  static const String security = '/security';
  static const String language = '/language';
  static const String privacy = '/privacy';
  static const String help = '/help';
  static const String invite = '/invite';
  static const String changePassword = '/change-password';
  static const String lessonDetail = '/lesson-detail';
  static const String quizResultDetail = '/quiz-result-detail';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/detail';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminCourses = '/admin/courses';
  static const String adminCategories = '/admin/categories';
  static const String mentorCourseManagement = '/mentor/courses';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AppEntryGate());
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
      case notificationSetting:
        page = NotificationSettingScreen();
        break;
      case bookmark:
        page = BookmarkScreen(userUid: settings.arguments as String);
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
      case quizList:
        page = const QuizListScreen();
        break;
      case quizDetail:
        page = const QuizDetailScreen();
        break;
      case quizQuestions:
        final args = settings.arguments;
        if (args is int) {
          page = QuizQuestionsScreen(quizId: args);
        } else if (args is Map<String, dynamic>) {
          page = QuizQuestionsScreen(
            quizId: args['quizId'],
            quizInfo: args['quizInfo'],
          );
        } else {
          page = const Scaffold(
            body: Center(child: Text('Không tìm thấy Quiz ID')),
          );
        }
        break;
      case courseDetail:
        final args = settings.arguments;
        if (args is int) {
          page = BlocProvider(
            create:
                (context) =>
                    CourseDetailCubit(context.read<CourseRepository>())
                      ..fetchCourseDetail(args),
            child: CourseDetailScreen(courseId: args),
          );
        } else {
          page = const Scaffold(
            body: Center(child: Text('Không tìm thấy Course ID')),
          );
        }
        break;
      case lessonDetail:
        final args = settings.arguments;
        if (args is int) {
          page = BlocProvider(
            create: (context) => LessonsCubit()..loadLessonDetail(args),
            child: LessonDetailScreen(lessonId: args, courseId: args),
          );
        } else {
          page = const Scaffold(
            body: Center(child: Text('Không tìm thấy Lesson ID')),
          );
        }
        break;
      case mentorDetail:
        final args = settings.arguments;
        if (args is String) {
          page = UserDetailScreen(uid: args);
        } else {
          page = const Scaffold(
            body: Center(child: Text('Không tìm thấy Mentor UID')),
          );
        }
        break;
      case payment:
        page = const PaymentScreen();
        break;
      case security:
        page = const SecurityScreen();
        break;
      case language:
        page = const LanguageScreen();
        break;
      case privacy:
        page = const PrivacyScreen();
        break;
      case help:
        page = const HelpScreen();
        break;
      case invite:
        page = const InviteScreen();
        break;
      case changePassword:
        page = const ChangePasswordScreen();
        break;
      case quizResultDetail:
        page = const QuizResultDetailScreen();
        break;
      case adminUsers:
        page = const UserManagementScreen();
        break;
      case adminUserDetail:
        final args = settings.arguments;
        if (args is String) {
          page = UserDetailScreen(uid: args);
        } else {
          page = const Scaffold(
            body: Center(child: Text('Không tìm thấy User UID')),
          );
        }
        break;
      case adminDashboard:
        page = const AdminDashboardScreen();
        break;
      case adminCourses:
        page = const CourseManagementAdminScreen();
        break;
      case adminCategories:
        page = const CategoryManagementScreen();
        break;
      case mentorCourseManagement:
        page = const CourseManagementScreen();
        break;
      default:
        page = const Scaffold(
          body: Center(child: Text('Không tìm thấy trang')),
        );
    }

    return _buildAnimatedRoute(page, settings);
  }

  /// Hevới hiệu ứng slide + fade hiện đại, mượt mà.
  static PageRouteBuilder _buildAnimatedRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide animation từ dưới lên
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.1), // Slide nhẹ từ dưới lên
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic, // Curve mượt mà hơn
            reverseCurve: Curves.easeInCubic,
          ),
        );

        // Fade animation với timing tối ưu
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
    );
  }
}
