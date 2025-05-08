import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/screens/dashboard/dashboard_screen.dart';
import 'package:lms/screens/home/home_screen.dart';
import 'package:lms/screens/myCourse/my_course_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';
import 'package:lms/screens/quiz/quiz_screen.dart';

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

    // 2) Lấy role từ UserBloc, chỉ rebuild khi role thay đổi
    final isAdminOrMentor = context.select<UserBloc, bool>((bloc) {
      final s = bloc.state;
      return s is UserLoaded &&
          (s.user.role == 'admin' || s.user.role == 'mentor');
    });

    // 3) Build danh sách màn hình và items động theo role
    final screens = <Widget>[
      const HomeScreen(),
      const MyCourseScreen(),
      const QuizScreen(),
      if (isAdminOrMentor) const DashboardScreen(),
      const ProfileScreen(),
    ];

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
      if (isAdminOrMentor)
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

    // 4) Clamp index để tránh out-of-bounds khi số tab thay đổi
    final safeIndex = _selectedIndex.clamp(0, screens.length - 1);

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
        backgroundColor: theme.colorScheme.surface,
        elevation: 8,
        items: items,
      ),
    );
  }
}
