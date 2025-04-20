import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/signup/signup_screen.dart'; // Import ThemeBloc

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image/Illustration section
                Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/images/login_light.png' // Ảnh cho theme sáng
                      : 'assets/images/login_dark.png', // Ảnh cho theme tối
                  height: 200,
                ),
                const SizedBox(height: 15),
                Center(
                  child: const Text(
                    "Chào mừng bạn đến\nhãy bắt đầu hành trình học hỏi!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 35),

                // Button sections for Facebook, Google, Apple
                SocialLoginButton(
                  context: context, // Truyền context
                  assetPath: 'assets/icons/facebook.png',
                  text: 'Tiếp tục với Facebook',
                  onPressed: () {
                    print('fb');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Apple button pressed')),
                    );
                  },
                ),
                const SizedBox(height: 16),

                SocialLoginButton(
                  context: context, // Truyền context
                  assetPath: 'assets/icons/google.png',
                  text: 'Tiếp tục với google',
                  onPressed: () {
                    print('google');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Apple button pressed')),
                    );
                  },
                ),
                const SizedBox(height: 16),
                SocialLoginButton(
                  context: context, // Truyền context
                  assetPath: 'assets/icons/apple.png',
                  text: 'Tiếp tục với Apple',
                  finalIconColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors
                              .black // Màu icon cho theme sáng
                          : Colors.white, // Màu icon cho theme tối

                  onPressed: () {
                    print('Apple button pressed');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Apple button pressed')),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text("hoặc"),
                const SizedBox(height: 20),
                // Sign in with password
                botton(
                  themeState: themeState,
                  text: 'Đăng nhập với mật khẩu',
                  onPressed: () {
                    Navigator.pushNamed(context, '/loginwithpassword');
                  },
                ),
                const SizedBox(height: 20),
                // Don't have an account section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ),
                        );
                      },
                      child: const Text("Đăng ký"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
