// lib/apps/utils/app_bar_home.dart

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
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
    elevation: 0,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                final role = (state is UserLoaded) ? state.user.role : null;
                final avatarUrl =
                    (state is UserLoaded && state.user.avatarUrl.isNotEmpty)
                        ? ApiConfig.getImageUrl(state.user.avatarUrl)
                        : defaultAvatar;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (role == 'admin' || role == 'mentor') {
                      // Navigator.pushNamed(context, AppRouter.dashBoard);
                    } else {
                      Navigator.pushNamed(context, AppRouter.profile);
                    }
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    backgroundImage: CachedNetworkImageProvider(avatarUrl),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      loiChao,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      speed: const Duration(milliseconds: 300),
                    ),
                  ],
                  pause: const Duration(milliseconds: 1000),
                  isRepeatingAnimation: false,
                ),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return Text(
                        state.user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
              onPressed: () => Navigator.pushNamed(context, AppRouter.bookmark),
            ),
            IconButton(
              icon: Image.asset(
                'assets/icons/notification.png',
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    AppRouter.notificationSetting,
                  ),
            ),
          ],
        ),
      ],
    ),
    toolbarHeight: 60,
  );
}
