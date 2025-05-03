import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';

AppBar AppBarHome(BuildContext context, String title) {
  const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';

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
                final role = (state is UserLoaded) ? state.user.role : null;
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (role == 'admin' || role == 'mentor') {
                      // điều hướng tới Dashboard
                      Navigator.pushNamed(context, '/dashBoard');
                    } else {
                      // điều hướng tới Profile bình thường
                    }
                  },
                  child: CircleAvatar(
                    backgroundImage:
                        (state is UserLoaded && state.user.avatarUrl.isNotEmpty)
                            ? NetworkImage(
                              '${ApiConfig.baseUrl}${state.user.avatarUrl}',
                            )
                            : const NetworkImage(defaultAvatar),
                  ),
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
