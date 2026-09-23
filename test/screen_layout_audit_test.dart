// test/screen_layout_audit_test.dart
//
// Quét lỗi bố cục trên các MÀN HÌNH THẬT, ở nhiều kích thước và cỡ chữ.
//
// `layout_responsive_test.dart` chỉ dựng vài widget rời (thẻ khoá học, trạng
// thái rỗng). File này dựng cả màn hình trong đúng hệ provider của `main.dart`
// — nơi lỗi bố cục thực sự xảy ra — và bắt:
//   1. tràn bố cục (`RenderFlex overflowed`),
//   2. exception khi render.
//
// Mọi service đều thất bại trong môi trường test (không có mạng), nên các màn
// hình này chạy qua nhánh lỗi/rỗng — đúng những nhánh vừa được sửa.
//
// Chạy: flutter test test/screen_layout_audit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/blocs/mentors/mentor_detail_bloc.dart';
import 'package:lms/blocs/mentors/mentors_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
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
import 'package:lms/repositories/mentor_repository.dart';
import 'package:lms/repositories/mentor_request_repository.dart';
import 'package:lms/repositories/question_repository.dart';
import 'package:lms/repositories/user_repository.dart';
import 'package:lms/screens/course_detail/course_detail_screen.dart';
import 'package:lms/screens/dashboard/admin/admin_dashboard_screen.dart';
import 'package:lms/screens/dashboard/admin/category_management_screen.dart';
import 'package:lms/screens/dashboard/admin/user_management_screen.dart';
import 'package:lms/screens/dashboard/mentor/mentor_dashboard_screen.dart';
import 'package:lms/screens/help/help_screen.dart';
import 'package:lms/screens/invite/invite_screen.dart';
import 'package:lms/screens/language/language_screen.dart';
import 'package:lms/screens/listCourse/listCourse_screen.dart';
import 'package:lms/screens/listMentor/listMentor_screen.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/mentor_request/mentor_request_admin_screen.dart';
import 'package:lms/screens/myCourse/my_course_screen.dart';
import 'package:lms/screens/notification/notification_setting_screen.dart';
import 'package:lms/screens/notification/notifications_screen.dart';
import 'package:lms/screens/payment/payment_screen.dart';
import 'package:lms/screens/privacy/privacy_screen.dart';
import 'package:lms/screens/security/security_screen.dart';
import 'package:lms/services/admin_user_service.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/services/bookmark_service.dart';
import 'package:lms/services/category_service.dart';
import 'package:lms/services/course_service.dart';
import 'package:lms/services/mentor_request_service.dart';
import 'package:lms/services/mentor_service.dart';
import 'package:lms/services/question_service.dart';
import 'package:lms/services/user_service.dart';

/// Kích thước đại diện: máy nhỏ nhất còn hỗ trợ, phổ thông, và tablet.
const _sizes = <String, Size>{
  'máy nhỏ 320x568': Size(320, 568),
  'phổ thông 390x844': Size(390, 844),
  'tablet 820x1180': Size(820, 1180),
};

/// Cỡ chữ hệ thống: mặc định và mức "Lớn" của Android/iOS.
const _scales = <double>[1.0, 1.3];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => initializeDateFormatting('vi', null));

  /// Dựng [screen] ở mọi kích thước × cỡ chữ, trả về mô tả lỗi gặp phải.
  Future<List<String>> audit(
    WidgetTester tester,
    Widget Function() build,
  ) async {
    final failures = <String>[];

    for (final entry in _sizes.entries) {
      for (final scale in _scales) {
        final label = '${entry.key} @ chữ x$scale';
        final errors = <String>[];
        final originalOnError = FlutterError.onError;

        FlutterError.onError = (details) {
          final buf = StringBuffer(details.exceptionAsString());
          final ctx = details.context;
          if (ctx != null) buf.write('\n  $ctx');
          errors.add(buf.toString());
        };

        try {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: entry.value,
                textScaler: TextScaler.linear(scale),
              ),
              child: _Harness(child: build()),
            ),
          );
          // Cho các future bất đồng bộ (đều thất bại) chạy xong.
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(seconds: 2));
        } finally {
          FlutterError.onError = originalOnError;
        }

        for (final e in errors) {
          if (e.contains('overflowed')) {
            final m = RegExp(
              r'overflowed by ([\d.]+) pixels on the (\w+)',
            ).firstMatch(e);
            failures.add(
              '$label: TRÀN ${m?.group(1) ?? '?'}px chiều '
              '${m?.group(2) ?? '?'}',
            );
          } else {
            failures.add('$label: lỗi render — ${e.split('\n').first}');
          }
        }

        final ex = tester.takeException();
        if (ex != null && !ex.toString().contains('overflowed')) {
          failures.add('$label: exception — ${ex.toString().split('\n').first}');
        }
      }
    }

    return failures;
  }

  /// Màn hình trong hệ provider đầy đủ, ở chế độ sáng và tối.
  for (final brightness in <(String, ThemeData)>[
    ('sáng', AppTheme.lightTheme),
    ('tối', AppTheme.darkTheme),
  ]) {
    final (modeName, themeData) = brightness;

    group('Bố cục — chế độ $modeName', () {
      final screens = <String, Widget Function()>{
        'PaymentScreen': () => const PaymentScreen(),
        'LanguageScreen': () => const LanguageScreen(),
        'HelpScreen': () => const HelpScreen(),
        'InviteScreen': () => const InviteScreen(),
        'PrivacyScreen': () => const PrivacyScreen(),
        'SecurityScreen': () => const SecurityScreen(),
        'NotificationsScreen': () => const NotificationsScreen(),
        'NotificationSettingScreen': () => const NotificationSettingScreen(),
        'MyCourseScreen': () => const MyCourseScreen(),
        'ListMentorScreen': () => const ListMentorScreen(),
        'ListCourseScreen': () => const ListCoursescreen(),
        'CategoryManagementScreen': () => const CategoryManagementScreen(),
        'UserManagementScreen': () => const UserManagementScreen(),
        'MentorRequestAdminScreen': () => const MentorRequestAdminScreen(),
        'AdminDashboardScreen': () => const AdminDashboardScreen(),
        'MentorDashboardScreen': () => const MentorDashboardScreen(),
        'CourseDetailScreen': () => const CourseDetailScreen(courseId: 1),
      };

      screens.forEach((name, build) {
        testWidgets(name, (tester) async {
          final failures = await audit(
            tester,
            () => Theme(data: themeData, child: build()),
          );
          expect(failures, isEmpty, reason: failures.join('\n'));
        });
      });
    });
  }
}

/// Bọc đúng hệ provider của `main.dart` để màn hình thật dựng được trong test.
class _Harness extends StatelessWidget {
  final Widget child;
  const _Harness({required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
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
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthService())),
          BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
          BlocProvider<UserBloc>(
            create: (_) => UserBloc(UserRepository(UserService())),
          ),
          BlocProvider<CourseCubit>(
            create: (_) => CourseCubit(CourseRepository(CourseService())),
          ),
          BlocProvider<CourseDetailCubit>(
            create: (_) => CourseDetailCubit(CourseRepository(CourseService())),
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
          BlocProvider<NotificationCubit>(create: (_) => NotificationCubit()),
          BlocProvider<LessonsCubit>(create: (_) => LessonsCubit()),
          BlocProvider<MentorsBloc>(
            create: (_) => MentorsBloc(MentorRepository(MentorService())),
          ),
          BlocProvider<MentorDetailBloc>(
            create: (_) => MentorDetailBloc(MentorRepository(MentorService())),
          ),
          BlocProvider<MentorRequestCubit>(
            create: (_) => MentorRequestCubit(
              MentorRequestRepository(MentorRequestService()),
            ),
          ),
        ],
        child: MaterialApp(theme: AppTheme.lightTheme, home: child),
      ),
    );
  }
}
