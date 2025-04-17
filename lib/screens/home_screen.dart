import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/screens/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String customToken;

  const HomeScreen({super.key, required this.customToken});

  // Hàm đăng xuất
  Future<void> _signOut(BuildContext context) async {
    try {
      // Đăng xuất từ Firebase
      await FirebaseAuth.instance.signOut();

      // Kiểm tra trạng thái đăng nhập sau khi đăng xuất
      User? user = FirebaseAuth.instance.currentUser;

      // Nếu người dùng đã đăng xuất (user == null), chuyển đến màn hình đăng nhập
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có vấn đề xảy ra khi đăng xuất
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi đăng xuất: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trang Chủ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị token của người dùng
            Text('Token của bạn: $customToken'),
            const SizedBox(height: 20),

            // Nút Đăng xuất
            ElevatedButton(
              onPressed:
                  () => _signOut(context), // Gọi hàm đăng xuất khi nhấn nút
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
