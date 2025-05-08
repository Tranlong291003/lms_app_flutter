import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import the loading animation package

class LoginWithPasswordScreen extends StatelessWidget {
  LoginWithPasswordScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else if (state is AuthFailure) {
          // Show error message if login fails
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: const Text(
                      'Chào mừng bạn trở lại!\nĐăng nhập để tiếp tục',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // TextField for email
                  CustomTextField(
                    labelText: 'Email',
                    controller: _emailController,
                    prefixAsset: 'assets/icons/email.png',
                  ),
                  const SizedBox(height: 20),
                  // TextField for password
                  CustomTextField(
                    labelText: 'Mật khẩu',
                    controller: _passwordController,
                    showVisibilityIcon: true,
                    obscureText: true,
                    prefixAsset: 'assets/icons/padlock.png',
                  ),
                  const SizedBox(height: 25),

                  // If loading, show a loading animation
                  if (state is AuthLoading)
                    Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: Colors.blue,
                        size: 50,
                      ),
                    )
                  else
                    // Login button
                    botton(
                      context: context,
                      text: 'Đăng nhập',
                      onPressed: () {
                        // Trigger the login Cubit with email and password
                        final email = _emailController.text;
                        final password = _passwordController.text;
                        if (email.isNotEmpty && password.isNotEmpty) {
                          context.read<AuthCubit>().loginWithEmailPassword(
                            email,
                            password,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter both email and password',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/forgotpassword');
                        },
                        child: Text(
                          "Quên mật khẩu",
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.displayLarge?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Hoặc đăng nhập bằng',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(
                        width: 70,
                        context: context,
                        assetPath: 'assets/icons/facebook.png',
                        onPressed: () {
                          // Handle Facebook login
                        },
                      ),
                      const SizedBox(width: 16),
                      SocialLoginButton(
                        width: 70,
                        context: context,
                        assetPath: 'assets/icons/google.png',
                        onPressed: () {
                          // Handle Google login
                        },
                      ),
                      const SizedBox(width: 16),
                      SocialLoginButton(
                        width: 70,
                        context: context,
                        assetPath: 'assets/icons/apple.png',
                        finalIconColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        onPressed: () {
                          // Handle Apple login
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text("Đăng ký"),
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
