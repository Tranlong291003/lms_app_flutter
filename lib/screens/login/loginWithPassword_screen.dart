import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/cubit/auth_state.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginWithPasswordScreen extends StatelessWidget {
  LoginWithPasswordScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final textPrimary =
        isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    final textSecondary =
        isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight;
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        } else if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Đăng nhập thất bại')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Hình minh hoạ hoặc icon lớn
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary.withOpacity(0.08),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.10),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            isDark
                                ? 'assets/images/login_dark.png'
                                : 'assets/images/login_light.png',
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.lock_outline,
                                  size: 70,
                                  color: AppTheme.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chào mừng bạn trở lại!',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Đăng nhập để tiếp tục sử dụng hệ thống LMS',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      Card(
                        color: surfaceColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 28,
                          ),
                          child: Column(
                            children: [
                              CustomTextField(
                                labelText: 'Email',
                                controller: _emailController,
                                prefixAsset: 'assets/icons/email.png',
                              ),
                              const SizedBox(height: 18),
                              CustomTextField(
                                labelText: 'Mật khẩu',
                                controller: _passwordController,
                                showVisibilityIcon: true,
                                obscureText: true,
                                prefixAsset: 'assets/icons/padlock.png',
                              ),
                              const SizedBox(height: 24),
                              if (state.status == AuthStatus.loading)
                                Center(
                                  child:
                                      LoadingAnimationWidget.fourRotatingDots(
                                        color: AppTheme.primary,
                                        size: 40,
                                      ),
                                )
                              else
                                botton(
                                  context: context,
                                  text: 'Đăng nhập',
                                  onPressed: () {
                                    final email = _emailController.text;
                                    final password = _passwordController.text;
                                    if (email.isNotEmpty &&
                                        password.isNotEmpty) {
                                      context.read<AuthCubit>().login(
                                        email,
                                        password,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Vui lòng nhập đầy đủ email và mật khẩu',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.forgotPassword,
                              );
                            },
                            child: Text(
                              "Quên mật khẩu",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Hoặc đăng nhập bằng',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialLoginButton(
                            width: 70,
                            context: context,
                            assetPath: 'assets/icons/facebook.png',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          SocialLoginButton(
                            width: 70,
                            context: context,
                            assetPath: 'assets/icons/google.png',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 16),
                          SocialLoginButton(
                            width: 70,
                            context: context,
                            assetPath: 'assets/icons/apple.png',
                            finalIconColor:
                                isDark ? Colors.white : Colors.black,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Chưa có tài khoản? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.signup);
                            },
                            child: Text(
                              "Đăng ký",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
