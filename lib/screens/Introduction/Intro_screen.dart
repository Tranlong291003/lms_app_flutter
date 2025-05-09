import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lms/screens/Introduction/cubit/intro_cubit.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageViewModel buildPage(String title, String body, String imageAsset) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(imageAsset, height: 300.0, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
      decoration: pageDecoration(),
    );
  }

  PageDecoration pageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyTextStyle: const TextStyle(fontSize: 24.0, color: Colors.white70),
      titlePadding: const EdgeInsets.only(top: 40, bottom: 20),
      bodyPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      imagePadding: const EdgeInsets.all(32),
      pageColor: Colors.transparent,
      contentMargin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Future<void> setIntroViewedAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isIntroViewed', true);
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          IntroductionScreen(
            globalBackgroundColor: Colors.transparent,
            showSkipButton: true,
            skip: const Text(
              "Bỏ qua",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            pages: [
              buildPage(
                "Chào mừng bạn đến với LearnPro",
                "Ứng dụng học tập với hàng trăm khoá học chất lượng, phù hợp với mọi đối tượng.",
                'assets/images/illustration1.png',
              ),
              buildPage(
                "Theo dõi tiến độ học tập",
                "Hệ thống giúp bạn dễ dàng theo dõi lộ trình và kết quả học tập của mình.",
                'assets/images/illustration2.png',
              ),
              buildPage(
                "Chứng chỉ hoàn thành",
                "Nhận ngay chứng chỉ uy tín khi hoàn thành mỗi khoá học.",
                'assets/images/illustration3.png',
              ),
            ],
            next: const Icon(Icons.arrow_forward, color: Colors.white),
            done: const Text(
              "Bắt đầu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            onSkip: () {
              context
                  .read<IntroCubit>()
                  .markIntroAsViewed(); // Đánh dấu intro đã xem
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            onDone: () {
              context
                  .read<IntroCubit>()
                  .markIntroAsViewed(); // Đánh dấu intro đã xem
              setIntroViewedAndNavigate(context);
            },
            dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeColor: Colors.white,
              color: Colors.white54,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
