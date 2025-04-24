import 'package:flutter/material.dart';

class EnrollButton extends StatelessWidget {
  const EnrollButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Thêm logic đăng ký ở đây
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Đăng ký khoá học miễn phí',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
