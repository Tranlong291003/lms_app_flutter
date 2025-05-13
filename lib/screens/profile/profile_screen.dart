import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';
import 'package:lms/blocs/user/user_bloc.dart';
import 'package:lms/blocs/user/user_event.dart';
import 'package:lms/blocs/user/user_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const defaultAvatar = 'https://www.gravatar.com/avatar/?d=mp';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Hồ sơ cá nhân', showMenu: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoaded) {
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor.withOpacity(0.8),
                                  theme.primaryColor,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.transparent,
                              child: CircleAvatar(
                                radius: 45,
                                backgroundImage:
                                    state.user.avatarUrl.isNotEmpty
                                        ? NetworkImage(
                                          ApiConfig.getImageUrl(
                                            state.user.avatarUrl,
                                          ),
                                        )
                                        : const NetworkImage(defaultAvatar),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                final currentUser =
                                    FirebaseAuth.instance.currentUser;
                                if (currentUser != null) {
                                  context.read<UserBloc>().add(
                                    GetUserByUidEvent(currentUser.uid),
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.editProfile,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.shadow
                                          .withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.user.name ?? 'Chưa cập nhật tên',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.user.email ?? 'Chưa cập nhật email',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                theme.primaryColor.withOpacity(0.8),
                                theme.primaryColor,
                              ],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.transparent,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundImage: NetworkImage(defaultAvatar),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withOpacity(
                                    0.1,
                                  ),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Đang tải...',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đang tải...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildSectionTitle('Tài khoản', theme),
                _buildMenuItem(
                  iconPath: "assets/icons/editprofile.png",
                  title: "Chỉnh sửa hồ sơ",
                  context: context,
                  onTap: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      context.read<UserBloc>().add(
                        GetUserByUidEvent(currentUser.uid),
                      );
                      Navigator.pushNamed(context, AppRouter.editProfile);
                    }
                  },
                ),
                _buildMenuItem(
                  iconPath: "assets/icons/notification.png",
                  title: "Thông báo",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.notificationSetting);
                  },
                ),
                _buildMenuItem(
                  iconPath: "assets/icons/payment.png",
                  title: "Thanh toán",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.payment);
                  },
                ),
                _buildMenuItem(
                  iconPath: "assets/icons/security.png",
                  title: "Bảo mật",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.security);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Cài đặt', theme),
                _buildMenuItem(
                  iconPath: "assets/icons/language.png",
                  title: "Ngôn ngữ",
                  trailing: const Text("Tiếng Việt"),
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.language);
                  },
                ),
                _buildMenuItem(
                  iconPath:
                      Theme.of(context).brightness == Brightness.dark
                          ? "assets/icons/lightmode.png"
                          : "assets/icons/darkmode.png",
                  title: "Chế độ tối",
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (_) {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    },
                  ),
                  context: context,
                ),
                _buildMenuItem(
                  iconPath: "assets/icons/privacy.png",
                  title: "Chính sách bảo mật",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.privacy);
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Hỗ trợ', theme),
                _buildMenuItem(
                  iconPath: "assets/icons/helpcenter.png",
                  title: "Trung tâm trợ giúp",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.help);
                  },
                ),
                _buildMenuItem(
                  iconPath: "assets/icons/logout.png",
                  title: "Đăng xuất",
                  context: context,
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () async {
                    final parentContext = context;
                    final confirm = await showModalBottomSheet<bool>(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      isScrollControlled: false,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Đăng xuất',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Hủy'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Đồng ý'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    if (confirm == true) {
                      await FirebaseAuth.instance.signOut();
                      if (parentContext.mounted) {
                        Navigator.pushReplacementNamed(
                          parentContext,
                          AppRouter.login,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String title,
    required BuildContext context,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          iconPath,
          width: 24,
          height: 24,
          color: iconColor ?? theme.colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: titleColor ?? theme.colorScheme.onSurface,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
        onTap: onTap,
      ),
    );
  }
}
