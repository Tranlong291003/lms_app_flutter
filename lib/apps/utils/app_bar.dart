import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';

AppBar appBar(BuildContext context, String title) {
  // Lấy giờ hiện tại
  int currentHour = DateTime.now().hour;

  // Xác định lời chào tùy theo thời gian trong ngày
  String greeting;
  if (currentHour >= 5 && currentHour < 12) {
    greeting = 'Good Morning 👋';
  } else if (currentHour >= 12 && currentHour < 18) {
    greeting = 'Good Afternoon 👋';
  } else {
    greeting = 'Good Evening 👋';
  }

  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0, // Bỏ bóng đổ
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                'https://www.example.com/your_image.jpg', // Thay đổi đường dẫn ảnh
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      greeting,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Làm chữ đậm
                        color: Colors.grey,
                      ),
                      speed: Duration(milliseconds: 300), // Tốc độ gõ chữ
                    ),
                  ],
                  pause: Duration(
                    milliseconds: 1000,
                  ), // Dừng 1 giây sau khi hoàn thành
                ),
                Text(
                  'Andrew Ainsley', // Tên người dùng
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                context.read<ThemeBloc>().add(ThemeToggled());
              },
            ),
            // Có thể thêm các icon khác ở đây nếu cần
          ],
        ),
      ],
    ),
    toolbarHeight: 80, // Tăng chiều cao của AppBar
  );
}
