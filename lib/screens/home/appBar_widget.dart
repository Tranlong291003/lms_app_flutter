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
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

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
    backgroundColor: colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    titleSpacing: 16,
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
          children: [
            Expanded(
              child: Row(
                children: [
                  BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      final avatarUrl =
                          (state is UserLoaded &&
                                  state.user.avatarUrl.isNotEmpty)
                              ? ApiConfig.getImageUrl(state.user.avatarUrl)
                              : defaultAvatar;

                      return InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.pushNamed(context, AppRouter.profile);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: colorScheme.surface,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              backgroundImage: CachedNetworkImageProvider(
                                avatarUrl,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              loiChao,
                              textStyle: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                              speed: const Duration(milliseconds: 150),
                            ),
                          ],
                          pause: const Duration(milliseconds: 1000),
                          isRepeatingAnimation: false,
                        ),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            final name =
                                state is UserLoaded ? state.user.name : 'User';
                            return Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _AppBarAction(
                  icon: Icons.bookmark_border_rounded,
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
                const SizedBox(width: 8),
                BlocBuilder<NotificationCubit, NotificationState>(
                  builder: (context, state) {
                    int unreadCount = 0;
                    if (state is NotificationLoaded) {
                      unreadCount =
                          state.notifications.where((n) => !n.isRead).length;
                    }
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _AppBarAction(
                          icon: Icons.notifications_none_rounded,
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
                            right: -2,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(minWidth: 22),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onError,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
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
    toolbarHeight: 72,
  );
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
        ),
      ),
    );
  }
}
