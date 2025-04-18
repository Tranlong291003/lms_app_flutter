import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/utils/app_bar.dart';
import 'package:lms/screens/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      appBar: appBar(context, 'title'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị token của người dùng
            Text('Token của bạn: ${FirebaseAuth.instance.currentUser?.uid}'),
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
