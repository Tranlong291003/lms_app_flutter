// test/screen_smoke_test.dart
//
// Smoke test: dựng từng màn hình trong môi trường test để phát hiện lỗi runtime
// (assert, null, overflow, exception khi build). Đây là lớp test chạy NHANH,
// không gọi mạng — mọi service đều thất bại trong test nên màn hình phải hiển
// thị trạng thái lỗi/rỗng thay vì sập.
//
// Chạy: flutter test test/screen_smoke_test.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/cubits/admin/admin_user_cubit.dart';
import 'package:lms/cubits/bookmark/bookmark_cubit.dart';
import 'package:lms/cubits/category/category_cubit.dart';
import 'package:lms/cubits/courses/course_cubit.dart';
import 'package:lms/cubits/lessons/lessons_cubit.dart';
import 'package:lms/cubits/mentor_request_cubit.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/cubits/question/question_cubit.dart';
import 'package:lms/cubits/reviews/review_cubit.dart';
import 'package:lms/repositories/admin_user_repository.dart';
import 'package:lms/repositories/bookmark_repository.dart';
import 'package:lms/repositories/category_repository.dart';
import 'package:lms/repositories/course_repository.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/repositories/mentor_repository.dart';
import 'package:lms/repositories/mentor_request_repository.dart';
import 'package:lms/repositories/user_repository.dart';
import 'package:lms/screens/Introduction/intro_screen.dart';
import 'package:lms/screens/forgotpassword/forgotpassword_screen.dart';
import 'package:lms/screens/help/help_screen.dart';
import 'package:lms/screens/invite/invite_screen.dart';
import 'package:lms/screens/language/language_screen.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/notification/notification_setting_screen.dart';
import 'package:lms/screens/payment/payment_screen.dart';
import 'package:lms/screens/privacy/privacy_screen.dart';
import 'package:lms/screens/security/change_password_screen.dart';
import 'package:lms/screens/security/security_screen.dart';
import 'package:lms/screens/signup/signup_screen.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/dashboard/admin/admin_dashboard_screen.dart';
import 'package:lms/screens/dashboard/admin/category_management_screen.dart';
import 'package:lms/screens/dashboard/admin/user_management_screen.dart';
import 'package:lms/screens/dashboard/mentor/mentor_dashboard_screen.dart';
import 'package:lms/screens/listCourse/listCourse_screen.dart';
import 'package:lms/screens/listMentor/listMentor_screen.dart';
import 'package:lms/screens/mentor_request/mentor_request_screen.dart';
import 'package:lms/screens/myCourse/my_course_screen.dart';
import 'package:lms/screens/notification/notifications_screen.dart';
import 'package:lms/screens/profile/editprofile_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';
import 'package:lms/screens/quiz/quiz_detail_screen.dart';
import 'package:lms/screens/quiz/quiz_list_screen.dart';
import 'package:lms/screens/splash_screen.dart';
import 'package:lms/screens/user_detail_screen.dart';
import 'package:lms/services/admin_user_service.dart';
import 'package:lms/services/bookmark_service.dart';
import 'package:lms/services/category_service.dart';
import 'package:lms/services/course_service.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/services/question_service.dart';
import 'package:lms/services/mentor_request_service.dart';
import 'package:lms/services/mentor_service.dart';
import 'package:lms/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // App gọi `initializeDateFormatting('vi')` trong main.dart; màn hình dùng
    // `DateFormat` với locale tiếng Việt nên test cũng phải khởi tạo.
    await initializeDateFormatting('vi', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Trong test, mọi request HTTP đều thất bại (flutter_test mock trả 400).
    // Đó chính là điều ta muốn: xác nhận màn hình chịu được lỗi mạng.
    HttpOverrides.global = null;
  });

  /// Dựng [screen] trong môi trường có đầy đủ Provider/Bloc mà app cung cấp.
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<UserRepository>(
            create: (_) => UserRepository(UserService()),
          ),
          RepositoryProvider<CourseRepository>(
            create: (_) => CourseRepository(CourseService()),
          ),
          RepositoryProvider<CategoryRepository>(
            create: (_) => CategoryRepository(CategoryService()),
          ),
          RepositoryProvider<BookmarkRepository>(
            create: (_) => BookmarkRepository(BookmarkService()),
          ),
          RepositoryProvider<AdminUserRepository>(
            create: (_) => AdminUserRepository(AdminUserService()),
          ),
          RepositoryProvider<QuestionRepository>(
            create: (_) => QuestionRepository(QuestionService()),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            // AuthCubit là provider gốc ở main.dart — thiếu nó thì các màn hình
            // đọc phiên đăng nhập sẽ ném ProviderNotFoundException.
            BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthService())),
            BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
            BlocProvider<UserBloc>(
              create: (_) => UserBloc(UserRepository(UserService())),
            ),
            BlocProvider<CourseCubit>(
              create: (_) => CourseCubit(CourseRepository(CourseService())),
            ),
            BlocProvider<CategoryCubit>(
              create: (_) =>
                  CategoryCubit(CategoryRepository(CategoryService())),
            ),
            BlocProvider<BookmarkCubit>(
              create: (_) =>
                  BookmarkCubit(BookmarkRepository(BookmarkService())),
            ),
            BlocProvider<AdminUserCubit>(
              create: (_) =>
                  AdminUserCubit(AdminUserRepository(AdminUserService())),
            ),
            BlocProvider<QuestionCubit>(
              create: (_) =>
                  QuestionCubit(QuestionRepository(QuestionService())),
            ),
            BlocProvider<ReviewCubit>(create: (_) => ReviewCubit()),
            BlocProvider<NotificationCubit>(
              create: (_) => NotificationCubit(),
            ),
            BlocProvider<LessonsCubit>(create: (_) => LessonsCubit()),
            BlocProvider<MentorsBloc>(
              create: (_) =>
                  MentorsBloc(MentorRepository(MentorService())),
            ),
            BlocProvider<MentorDetailBloc>(
              create: (_) =>
                  MentorDetailBloc(MentorRepository(MentorService())),
            ),
            BlocProvider<MentorRequestCubit>(
              create: (_) => MentorRequestCubit(
                MentorRequestRepository(MentorRequestService()),
              ),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: screen,
          ),
        ),
      ),
    );
    // Cho các future bất đồng bộ (đều thất bại) chạy xong, rồi vượt qua cả
    // timeout của Dio để không còn timer treo khi test kết thúc.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 25));
  }

  /// Màn hình không được ném lỗi khi build/render.
  void expectNoException(WidgetTester tester) {
    final error = tester.takeException();
    expect(
      error,
      isNull,
      reason: 'Màn hình ném lỗi khi render: $error',
    );
  }

  group('Màn hình khởi động & xác thực', () {
    testWidgets('SplashScreen render được', (tester) async {
      await pumpScreen(tester, const SplashScreen());
      expectNoException(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      // SplashScreen hẹn chuyển trang sau 2 giây; để timer chạy hết trong test
      // này, nếu không sẽ báo "A Timer is still pending".
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('LoginScreen render được', (tester) async {
      await pumpScreen(tester, const LoginScreen());
      expectNoException(tester);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('LoginWithPasswordScreen render được', (tester) async {
      await pumpScreen(tester, LoginWithPasswordScreen());
      expectNoException(tester);
      // Phải có ô nhập email và mật khẩu.
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('SignUpScreen render được', (tester) async {
      await pumpScreen(tester, const SignUpScreen());
      expectNoException(tester);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('ForgotpasswordScreen render được', (tester) async {
      await pumpScreen(tester, const ForgotpasswordScreen());
      expectNoException(tester);
    });

    testWidgets('IntroScreen render được', (tester) async {
      await pumpScreen(tester, const IntroScreen());
      expectNoException(tester);
    });

    testWidgets('ChangePasswordScreen render được', (tester) async {
      await pumpScreen(tester, const ChangePasswordScreen());
      expectNoException(tester);
    });
  });

  group('Màn hình chính', () {
    testWidgets('ListMentorScreen render được', (tester) async {
      await pumpScreen(tester, const ListMentorScreen());
      expectNoException(tester);
    });

    testWidgets('ListCoursescreen render được', (tester) async {
      await pumpScreen(tester, const ListCoursescreen());
      expectNoException(tester);
    });

    testWidgets('MyCourseScreen render được', (tester) async {
      await pumpScreen(tester, const MyCourseScreen());
      expectNoException(tester);
    });

    testWidgets('NotificationsScreen render được', (tester) async {
      await pumpScreen(tester, const NotificationsScreen());
      expectNoException(tester);
    });

    testWidgets('ProfileScreen render được', (tester) async {
      await pumpScreen(tester, const ProfileScreen());
      expectNoException(tester);
    });

    testWidgets('EditProfileScreen render được', (tester) async {
      await pumpScreen(tester, const EditProfileScreen());
      expectNoException(tester);
    });

    testWidgets('QuizListScreen render được', (tester) async {
      await pumpScreen(tester, const QuizListScreen());
      expectNoException(tester);
    });

    testWidgets('MentorRequestScreen render được', (tester) async {
      await pumpScreen(tester, const MentorRequestScreen());
      expectNoException(tester);
    });
  });

  group('Màn hình dashboard', () {
    testWidgets('AdminDashboardScreen render được', (tester) async {
      await pumpScreen(tester, const AdminDashboardScreen());
      expectNoException(tester);
    });

    testWidgets('MentorDashboardScreen render được', (tester) async {
      await pumpScreen(tester, const MentorDashboardScreen());
      expectNoException(tester);
    });

    testWidgets('UserManagementScreen render được', (tester) async {
      await pumpScreen(tester, const UserManagementScreen());
      expectNoException(tester);
    });

    testWidgets('CategoryManagementScreen render được', (tester) async {
      await pumpScreen(tester, const CategoryManagementScreen());
      expectNoException(tester);
    });
  });

  group('Màn hình chi tiết (có tham số)', () {
    testWidgets('CourseDetailScreen render được (API lỗi)', (tester) async {
      // Trong app, CourseDetailCubit được cung cấp ngay tại route
      // (AppRouter.generateRoute) nên test phải tự bọc.
      await pumpScreen(
        tester,
        BlocProvider<CourseDetailCubit>(
          create: (_) =>
              CourseDetailCubit(CourseRepository(CourseService())),
          child: const CourseDetailScreen(courseId: 1),
        ),
      );
      expectNoException(tester);
    });

    testWidgets('UserDetailScreen render được (API lỗi)', (tester) async {
      await pumpScreen(tester, const UserDetailScreen(uid: 'khong-ton-tai'));
      expectNoException(tester);
    });

    testWidgets('QuizDetailScreen render được', (tester) async {
      await pumpScreen(tester, const QuizDetailScreen());
      expectNoException(tester);
    });
  });

  group('Màn hình cài đặt', () {
    testWidgets('SecurityScreen render được', (tester) async {
      await pumpScreen(tester, const SecurityScreen());
      expectNoException(tester);
    });

    testWidgets('LanguageScreen render được', (tester) async {
      await pumpScreen(tester, const LanguageScreen());
      expectNoException(tester);
    });

    testWidgets('PrivacyScreen render được', (tester) async {
      await pumpScreen(tester, const PrivacyScreen());
      expectNoException(tester);
    });

    testWidgets('HelpScreen render được', (tester) async {
      await pumpScreen(tester, const HelpScreen());
      expectNoException(tester);
    });

    testWidgets('InviteScreen render được', (tester) async {
      await pumpScreen(tester, const InviteScreen());
      expectNoException(tester);
    });

    testWidgets('PaymentScreen render được', (tester) async {
      await pumpScreen(tester, const PaymentScreen());
      expectNoException(tester);
    });

    testWidgets('NotificationSettingScreen render được', (tester) async {
      await pumpScreen(tester, const NotificationSettingScreen());
      expectNoException(tester);
    });
  });
}
