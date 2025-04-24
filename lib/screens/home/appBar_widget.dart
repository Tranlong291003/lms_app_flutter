import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';

AppBar AppBarHome(BuildContext context, String title) {
  const defaultAvatar =
      'https://media.istockphoto.com/id/1300845620/vector/user-icon-flat-isolated-on-white-background-user-symbol-vector-illustration.jpg?s=612x612&w=0&k=20&c=yBeyba0hUkh14_jgv1OKqIH0CCSWU_4ckRkAoy2p73o=';

  // Lấy giờ hiện tại
  int gioHienTai = DateTime.now().hour;

  // Xác định lời chào theo khung giờ trong ngày
  String loiChao;
  if (gioHienTai >= 5 && gioHienTai < 12) {
    loiChao = 'Chào buổi sáng 👋';
  } else if (gioHienTai >= 12 && gioHienTai < 18) {
    loiChao = 'Chào buổi chiều 👋';
  } else {
    loiChao = 'Chào buổi tối 👋';
  }

  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0, // Gỡ bỏ bóng đổ
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  return CircleAvatar(
                    backgroundImage:
                        state.user.avatarUrl != null &&
                                state.user.avatarUrl!.isNotEmpty
                            ? NetworkImage(
                              '${ApiConfig.baseUrl}${state.user.avatarUrl}',
                            )
                            : const NetworkImage(defaultAvatar),
                  );
                }
                return const CircleAvatar(
                  backgroundImage: NetworkImage(defaultAvatar),
                );
              },
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      // Hiển thị lời chào động
                      loiChao,
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Chữ đậm
                        color: Colors.grey,
                      ),
                      speed: Duration(milliseconds: 300), // Tốc độ gõ
                    ),
                  ],
                  pause: Duration(milliseconds: 1000), // Dừng 1 giây
                ),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return Text(
                        state.user.name ?? 'User', // Tên người dùng từ UserBloc
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, // Chữ đậm
                        ),
                      );
                    }
                    return const Text(
                      'User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
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
                // Chuyển theme sáng/tối
                context.read<ThemeBloc>().add(ThemeToggled());
              },
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/bookmark.png',
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/bookmark');
              },
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/notification.png',
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/notification');
              },
            ),
          ],
        ),
      ],
    ),
    toolbarHeight: 60, // Tăng chiều cao AppBar
  );
}
