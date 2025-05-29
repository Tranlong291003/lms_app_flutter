// lib/apps/utils/app_bar_home.dart

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/cubits/notifications/notification_state.dart';
import 'package:lms/screens/notification/notifications_screen.dart';

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
    title: Builder(
      builder: (context) {
        // Luôn load notification khi app bar được build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final cubit = BlocProvider.of<NotificationCubit>(
            context,
            listen: false,
          );
          cubit.loadNotifications();
        });
        return Row(
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
                        Navigator.pushNamed(context, AppRouter.profile);
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
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.bookmark,
                        arguments: currentUser.uid,
                      );
                    } else {
                      // Hiển thị thông báo yêu cầu đăng nhập nếu chưa đăng nhập
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng đăng nhập để xem bookmark'),
                        ),
                      );
                    }
                  },
                ),
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    int unreadCount = 0;
                    if (state is NotificationLoaded) {
                      unreadCount =
                          state.notifications.where((n) => !n.isRead).length;
                    }
                    return Stack(
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/icons/notification.png',
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    ),
    toolbarHeight: 60,
  );
}
