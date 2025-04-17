// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:lms/apps/config/api_config.dart';
// import 'package:lms/screens/home_screen.dart'; // Import HomeScreen

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   // Khởi tạo Dio để gửi yêu cầu HTTP
//   final Dio _dio = Dio();

//   Future<void> _onLoginPressed() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();

//     try {
//       // Đăng nhập Firebase bằng email và mật khẩu
//       UserCredential userCredential = await FirebaseAuth.instance
//           .signInWithEmailAndPassword(email: email, password: password);

//       // Lấy ID Token sau khi đăng nhập thành công
//       String? idToken = await userCredential.user!.getIdToken();

//       if (idToken == null) {
//         // Xử lý trường hợp idToken là null
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Lỗi: Không thể lấy ID Token')));
//         return;
//       }

//       // Gửi ID Token đến backend để xác thực và nhận Custom Token
//       final response = await _dio.post(
//         ApiConfig.login,
//         data: {'idToken': idToken},
//       );

//       if (response.statusCode == 200) {
//         // Đăng nhập thành công, lấy Custom Token
//         String customToken = response.data['custom_token'];

//         // Chuyển đến HomeScreen và truyền Custom Token
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HomeScreen(customToken: customToken),
//           ),
//         );
//       } else {
//         // Lỗi từ backend
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Lỗi từ backend')));
//       }
//     } catch (e) {
//       // Xử lý lỗi đăng nhập
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng nhập: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Đăng nhập')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Mật khẩu'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: _onLoginPressed,
//               child: const Text('Đăng nhập'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/app_bar.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/signup/signup_screen.dart'; // Import ThemeBloc

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: appBar(context, "Đăng nhập"), // AppBar
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
                  height: 230,
                ),
                const SizedBox(height: 20),
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
                    // Điều hướng đến màn hình LoginWithPasswordScreen khi nhấn nút
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginWithPasswordScreen(),
                      ),
                    );
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
