import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/app_bar.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: appBar(context, 'test'),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tiêu đề
                  const Text(
                    'Tạo tài khoản của bạn',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  CustomTextField(
                    labelText: 'Họ và tên',
                    controller: _nameController,
                    prefixAsset:
                        'assets/icons/user.png', // Thay bằng asset email của bạn
                  ),
                  const SizedBox(height: 20),
                  // TextField cho Email
                  CustomTextField(
                    labelText: 'Email',
                    controller: _emailController,
                    prefixAsset:
                        'assets/icons/email.png', // Thay bằng asset email của bạn
                  ),

                  const SizedBox(height: 20),

                  // TextField cho Mật khẩu
                  CustomTextField(
                    labelText: 'Mật khẩu',
                    controller: _passwordController,
                    showVisibilityIcon: true,
                    obscureText: true,
                    prefixAsset: 'assets/icons/padlock.png',
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    labelText: 'Nhập lại mật khẩu',
                    controller: _passwordController,
                    showVisibilityIcon: true,
                    obscureText: true,
                    prefixAsset: 'assets/icons/padlock.png',
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    labelText: 'Số điện thoại',
                    controller: _phoneController,
                    prefixAsset: 'assets/icons/telephone.png',
                  ),
                  const SizedBox(height: 25),

                  botton(
                    themeState: themeState,
                    text: 'Đăng ký',
                    onPressed: () {
                      // Điều hướng đến màn hình LoginWithPasswordScreen khi nhấn nút
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => LoginWithPasswordScreen(),
                      //   ),
                      // );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Hoặc Đăng nhập qua mạng xã hội
                  const Text(
                    'Hoặc đăng nhập bằng',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút Facebook
                      SocialLoginButton(
                        width: 70,
                        context: context, // Truyền context
                        assetPath: 'assets/icons/facebook.png',
                        onPressed: () {
                          print('fb');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Apple button pressed')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),

                      SocialLoginButton(
                        width: 70,
                        context: context, // Truyền context
                        assetPath: 'assets/icons/google.png',
                        onPressed: () {
                          print('google');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Apple button pressed')),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      SocialLoginButton(
                        width: 70,
                        context: context, // Truyền context
                        assetPath: 'assets/icons/apple.png',
                        finalIconColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors
                                    .black // Màu icon cho theme sáng
                                : Colors.white, // Màu icon cho theme tối
                        onPressed: () {
                          print('Apple button pressed');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Apple button pressed')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Đã có tài khoản? Đăng nhập
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Đã có tài khoản? "),
                      TextButton(
                        onPressed: null,
                        child: const Text("Đăng nhập"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
