import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/home/home_screen.dart';
import 'package:lms/screens/myCourse/myCourse_screen.dart';
import 'package:lms/screens/profile/profile_screen.dart';

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0; // Chỉ số mặc định, "Trang chủ" được chọn đầu tiên

  // Các màn hình cho mỗi tab trong thanh điều hướng
  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MyCourseScreen(),
    InboxScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex, // Đảm bảo không xây dựng lại widget
            children: _widgetOptions,
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Color(0xFF335ef7), // Màu cho mục được chọn
            unselectedItemColor: Colors.grey[600], // Màu cho mục không chọn
            type:
                BottomNavigationBarType.fixed, // Không thay đổi kích thước mục
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            unselectedFontSize: 12, // Kích thước font cho mục không chọn
            selectedFontSize: 14, // Kích thước font cho mục được chọn
            selectedLabelStyle: GoogleFonts.roboto(
              fontWeight:
                  FontWeight.w500, // Đổi font chữ cho nhãn mục được chọn
            ),
            unselectedLabelStyle: GoogleFonts.roboto(
              fontWeight:
                  FontWeight.w400, // Đổi font chữ cho nhãn mục không chọn
            ),
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/home.png', color: Colors.grey),
                label: 'Trang chủ',
                activeIcon: Image.asset(
                  'assets/icons/home.png',
                  color: Color(0xFF335ef7),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/course.png',
                  color: Colors.grey,
                ),
                label: 'Khoá học',
                activeIcon: Image.asset(
                  'assets/icons/course.png',
                  color: Color(0xFF335ef7),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/quiz.png', color: Colors.grey),
                label: 'Quiz',
                activeIcon: Image.asset(
                  'assets/icons/quiz.png',
                  color: Color(0xFF335ef7),
                ),
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/icons/profile.png',
                  color: Colors.grey,
                ),
                label: 'Cá nhân',
                activeIcon: Image.asset(
                  'assets/icons/profile.png',
                  color: Color(0xFF335ef7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Màn hình Hộp thư đến'));
  }
}
