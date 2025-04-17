import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/screens/home_screen.dart'; // Import HomeScreen

class LoginWithPasswordScreen extends StatefulWidget {
  const LoginWithPasswordScreen({super.key});

  @override
  State<LoginWithPasswordScreen> createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Khởi tạo Dio để gửi yêu cầu HTTP
  final Dio _dio = Dio();

  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Đăng nhập Firebase bằng email và mật khẩu
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Lấy ID Token sau khi đăng nhập thành công
      String? idToken = await userCredential.user!.getIdToken();

      if (idToken == null) {
        // Xử lý trường hợp idToken là null
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: Không thể lấy ID Token')));
        return;
      }

      // Gửi ID Token đến backend để xác thực và nhận Custom Token
      final response = await _dio.post(
        ApiConfig.login,
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        // Đăng nhập thành công, lấy Custom Token
        String customToken = response.data['custom_token'];

        // Chuyển đến HomeScreen và truyền Custom Token
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(customToken: customToken),
          ),
        );
      } else {
        // Lỗi từ backend
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi từ backend')));
      }
    } catch (e) {
      // Xử lý lỗi đăng nhập
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng nhập: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập với mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nhập email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            // Nhập mật khẩu
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true, // Ẩn mật khẩu
            ),
            const SizedBox(height: 32),
            // Nút đăng nhập
            ElevatedButton(
              onPressed: _onLoginPressed,
              child: const Text('Đăng nhập'),
            ),
            const SizedBox(height: 16),
            // Tạo tài khoản mới
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Chưa có tài khoản? "),
                TextButton(
                  onPressed: () {
                    // Điều hướng đến màn hình đăng ký (Sign Up)
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                  },
                  child: const Text("Đăng ký"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
