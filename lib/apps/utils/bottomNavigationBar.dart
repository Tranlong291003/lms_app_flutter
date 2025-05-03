import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
    // 1) Check brightness: nếu Dark Mode thì dùng trắng, ngược lại dùng xanh
    final activeColor = const Color(0xFF335EF7);

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
        icon: Image.asset('assets/icons/home.png', color: Colors.grey),
        activeIcon: Image.asset('assets/icons/home.png', color: activeColor),
        label: 'Trang chủ',
      ),
      BottomNavigationBarItem(
        icon: Image.asset('assets/icons/course.png', color: Colors.grey),
        activeIcon: Image.asset('assets/icons/course.png', color: activeColor),
        label: 'Khoá học',
      ),
      BottomNavigationBarItem(
        icon: Image.asset('assets/icons/quiz.png', color: Colors.grey),
        activeIcon: Image.asset('assets/icons/quiz.png', color: activeColor),
        label: 'Quiz',
      ),
      if (isAdminOrMentor)
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard, color: Colors.grey),
          activeIcon: Icon(Icons.dashboard, color: activeColor),
          label: 'Dashboard',
        ),
      BottomNavigationBarItem(
        icon: Image.asset('assets/icons/profile.png', color: Colors.grey),
        activeIcon: Image.asset('assets/icons/profile.png', color: activeColor),
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
        selectedItemColor: activeColor,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        unselectedLabelStyle: GoogleFonts.roboto(fontWeight: FontWeight.w400),
        items: items,
      ),
    );
  }
}
