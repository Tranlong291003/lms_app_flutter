import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/customAppBar.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_event.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Hồ sơ cá nhân', showMenu: true),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/32.jpg',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, size: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Andrew Ainsley',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'andrew_ainsley@yourdomain.com',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  "assets/icons/editprofile.png",
                  "Chỉnh sửa hồ sơ",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, '/editprofile');
                  },
                ),
                _buildMenuItem(
                  "assets/icons/notification.png",
                  "Thông báo",
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/payment.png",
                  "Thanh toán",
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/security.png",
                  "Bảo mật",
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/language.png",
                  "Ngôn ngữ",
                  trailing: const Text("Tiếng Anh (US)"),
                  context: context,
                ),
                _buildMenuItem(
                  Theme.of(context).brightness == Brightness.dark
                      ? "assets/icons/lightmode.png"
                      : "assets/icons/darkmode.png",
                  "Chế độ tối",
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (_) {
                      context.read<ThemeBloc>().add(ThemeToggled());
                    },
                  ),
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/privacy.png",
                  "Chính sách bảo mật",
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/helpcenter.png",
                  "Trung tâm trợ giúp",
                  context: context,
                ),
                _buildMenuItem(
                  "assets/icons/invitefriend.png",
                  "Mời bạn bè",
                  context: context,
                  onTap: () {
                    Navigator.pushNamed(context, '/courseDetail');
                  },
                ),
                _buildMenuItem(
                  "assets/icons/logout.png",
                  "Đăng xuất",
                  color: Colors.red,
                  context: context,
                  onTap: () async {
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
                              // Thanh kéo nhỏ
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Tiêu đề
                              const Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Nội dung xác nhận
                              const Text(
                                'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 24),

                              // Nút huỷ và đăng xuất
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
                      Navigator.pushReplacementNamed(context, '/login');
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

  Widget _buildMenuItem(
    String assetPath,
    String title, {
    Widget? trailing,
    Color? color,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ?? (isDark ? Colors.white : Colors.black87);

    return ListTile(
      leading: Image.asset(assetPath, width: 24, height: 24, color: iconColor),
      title: Text(title, style: TextStyle(color: iconColor)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap, // đã xử lý ở đây
    );
  }
}
