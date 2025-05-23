import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/screens/dashboard/admin/admin_dashboard_screen.dart';
import 'package:lms/screens/dashboard/mentor/mentor_dashboard_screen.dart';
import 'package:lms/screens/home/home_screen.dart';
import 'package:lms/screens/mentor_request/mentor_request_screen.dart';
import 'package:lms/screens/myCourse/my_course_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';
import 'package:lms/screens/quiz/quiz_list_screen.dart';

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  _BottomNavigationBarExampleState createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lấy role và tên user
    final userRole = context.select<UserBloc, String>(
      (bloc) =>
          (bloc.state is UserLoaded)
              ? (bloc.state as UserLoaded).user.role
              : '',
    );
    final userName = context.select<UserBloc, String>(
      (bloc) =>
          (bloc.state is UserLoaded)
              ? (bloc.state as UserLoaded).user.name
              : '',
    );

    // Xác định dashboardScreen phù hợp
    Widget? dashboardScreen;
    if (userRole == 'admin') {
      dashboardScreen = const AdminDashboardScreen();
    } else if (userRole == 'mentor') {
      dashboardScreen = const MentorDashboardScreen();
    }

    // Build danh sách màn hình
    final screens = <Widget>[
      const HomeScreen(),
      const MyCourseScreen(),
      const QuizListScreen(),
      if (dashboardScreen != null) dashboardScreen,
      const ProfileScreen(),
    ];
    // Thêm màn hình đăng ký mentor nếu là user
    if (userRole == 'user') {
      screens.insert(3, const MentorRequestScreen());
    }

    // Build danh sách item
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons/home.png',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        activeIcon: Image.asset(
          'assets/icons/home.png',
          color: theme.colorScheme.primary,
        ),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons/course.png',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        activeIcon: Image.asset(
          'assets/icons/course.png',
          color: theme.colorScheme.primary,
        ),
        label: 'Khoá học',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons/quiz.png',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        activeIcon: Image.asset(
          'assets/icons/quiz.png',
          color: theme.colorScheme.primary,
        ),
        label: 'Quiz',
      ),
      if (userRole == 'user')
        BottomNavigationBarItem(
          icon: const Icon(Icons.school_outlined),
          activeIcon: const Icon(Icons.school),
          label: 'Đăng ký Mentor',
        ),
      if (dashboardScreen != null)
        BottomNavigationBarItem(
          icon: Icon(
            Icons.dashboard,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          activeIcon: Icon(Icons.dashboard, color: theme.colorScheme.primary),
          label: 'Dashboard',
        ),
      BottomNavigationBarItem(
        icon: Image.asset(
          'assets/icons/profile.png',
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        activeIcon: Image.asset(
          'assets/icons/profile.png',
          color: theme.colorScheme.primary,
        ),
        label: 'Cá nhân',
      ),
    ];

    // Clamp index để tránh out-of-bounds khi số tab thay đổi
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    // Nếu là user thì thêm nút tiện ích đăng ký mentor
    final isUser = userRole == 'user';

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: safeIndex,
        onTap: (idx) => setState(() => _selectedIndex = idx),
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        backgroundColor:
            theme.brightness == Brightness.dark
                ? const Color(0xFF181A20)
                : const Color(0xFFF8FAFC),
        elevation: 8,
        items: items,
      ),
    );
  }
}
