import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/signup/cubit/sign_up_cubit.dart';
import 'package:page_transition/page_transition.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: BlocBuilder<SignUpCubit, SignUpState>(
        builder: (context, state) {
          return Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40),
                    Text(
                      'Tạo tài khoản của bạn',
                      style: TextStyle(
                        fontSize: 30, // Kích thước chữ
                        fontWeight: FontWeight.bold, // Chữ đậm
                        fontFamily: 'Roboto', // Kiểu chữ (font family)
                        letterSpacing: 1.5, // Khoảng cách giữa các ký tự
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors
                                    .white // Màu chữ cho giao diện tối
                                : Colors.black, // Màu chữ cho giao diện sáng
                        shadows: [
                          Shadow(
                            blurRadius: 6.0, // Độ mờ của bóng
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    CustomTextField(
                      labelText: 'Họ và tên',
                      controller: _nameController,
                      prefixAsset: 'assets/icons/user.png',
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      labelText: 'Email',
                      controller: _emailController,
                      prefixAsset: 'assets/icons/email.png',
                    ),
                    const SizedBox(height: 20),
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
                      controller: _confirmPasswordController,
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
                    BlocBuilder<ThemeBloc, ThemeState>(
                      builder: (context, themeState) {
                        return botton(
                          themeState: themeState,
                          text: 'Đăng ký',
                          onPressed: () {
                            // Gọi hàm signUp từ SignUpCubit
                            context.read<SignUpCubit>().signUp(
                              context: context,
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              confirmPassword: _confirmPasswordController.text,
                              phone: _phoneController.text,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    if (state is SignUpFailure)
                      Text(state.message, style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    const Text(
                      'Hoặc đăng nhập bằng',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialLoginButton(
                          width: 70,
                          context: context,
                          assetPath: 'assets/icons/facebook.png',
                          onPressed: () {
                            print('fb');
                          },
                        ),
                        const SizedBox(width: 16),
                        SocialLoginButton(
                          width: 70,
                          context: context,
                          assetPath: 'assets/icons/google.png',
                          onPressed: () {
                            print('google');
                          },
                        ),
                        const SizedBox(width: 16),
                        SocialLoginButton(
                          width: 70,
                          context: context,
                          assetPath: 'assets/icons/apple.png',
                          onPressed: () {
                            print('Apple button pressed');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Đã có tài khoản?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                child: LoginWithPasswordScreen(),
                              ),
                            );
                          },
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
      ),
    );
  }
}
