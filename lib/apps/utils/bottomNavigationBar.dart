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

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Trang chủ',
      ),
      const NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book_rounded),
        label: 'Khoá học',
      ),
      const NavigationDestination(
        icon: Icon(Icons.quiz_outlined),
        selectedIcon: Icon(Icons.quiz_rounded),
        label: 'Quiz',
      ),
      if (userRole == 'user')
        const NavigationDestination(
          icon: Icon(Icons.workspace_premium_outlined),
          selectedIcon: Icon(Icons.workspace_premium_rounded),
          label: 'Mentor',
        ),
      if (dashboardScreen != null)
        const NavigationDestination(
          icon: Icon(Icons.dashboard_customize_outlined),
          selectedIcon: Icon(Icons.dashboard_customize_rounded),
          label: 'Dashboard',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Hồ sơ',
      ),
    ];

    // Clamp index để tránh out-of-bounds khi số tab thay đổi
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: screens),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.16)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(
                theme.brightness == Brightness.dark ? 0.35 : 0.08,
              ),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected:
                (idx) => setState(() => _selectedIndex = idx),
            height: 72,
            backgroundColor: Colors.transparent,
            elevation: 0,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}
