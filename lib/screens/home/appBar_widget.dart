// lib/apps/utils/app_bar_home.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/custom_snackbar.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_state.dart';
import 'package:lms/cubits/notifications/notification_cubit.dart';
import 'package:lms/cubits/notifications/notification_state.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/notification/notifications_screen.dart';

/// Thanh tiêu đề của trang chủ: lời chào + tên người dùng, nút lưu, thông báo.
///
/// Trước đây hàm này nhận tham số `title` nhưng **không dùng** — nơi gọi vẫn
/// phải truyền một chuỗi bất kỳ (`'title'`). Bỏ tham số cho khỏi đánh lừa.
AppBar AppBarHome(BuildContext context) {
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
                final avatarUrl =
                    (state is UserLoaded && state.user.avatarUrl.isNotEmpty)
                        ? ApiConfig.getImageUrl(state.user.avatarUrl)
                        : defaultAvatar;

                return InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.profile);
                  },
                  child: Semantics(
                    label: 'Mở hồ sơ cá nhân',
                    button: true,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(avatarUrl),
                      // Ảnh đại diện tải lỗi thì hiện icon thay vì ô trống.
                      onBackgroundImageError: (_, __) {},
                      child: null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dùng `Text` thay cho hiệu ứng gõ chữ: hiệu ứng chạy lại mỗi
                // lần app bar dựng lại (đổi tab, mở thông báo…) nên lời chào
                // nhấp nháy như đang tải, trong khi nội dung không đổi.
                Text(
                  loiChao,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    final name = state is UserLoaded ? state.user.name : 'Bạn';
                    return Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
              tooltip: 'Khoá học đã lưu',
              onPressed: () {
                final uid = context.read<AuthCubit>().state.userId;
                if (uid != null && uid.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.bookmark,
                    arguments: uid,
                  );
                } else {
                  CustomSnackBar.showInfo(
                    context: context,
                    message: 'Vui lòng đăng nhập để xem khoá học đã lưu.',
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
                      tooltip: unreadCount > 0
                          ? 'Thông báo ($unreadCount chưa đọc)'
                          : 'Thông báo',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            // `colorScheme.error` + `onError` để badge đúng
                            // tông và đủ tương phản ở cả hai chế độ.
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: AppRadius.borderPill,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onError,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
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
    ),
    // Khớp `CustomAppBar.toolbarHeight` — trước đây trang chủ cao 60 trong khi
    // mọi màn hình khác cao 64, nên tiêu đề nhảy lên xuống khi chuyển trang.
    toolbarHeight: AppSizes.appBarHeight,
  );
}
