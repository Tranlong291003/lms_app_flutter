import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/blocs/theme/theme_bloc.dart';
import 'package:lms/blocs/theme/theme_state.dart';
import 'package:lms/screens/signup/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
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
                      // Hình minh hoạ lớn phía trên
                      Container(
                        width: 160,
                        height: 160,
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
                                  Icons.person,
                                  size: 90,
                                  color: AppTheme.primary,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Chào mừng bạn đến!",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hãy bắt đầu hành trình học hỏi cùng LMS",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      // Button sections for Facebook, Google, Apple
                      SocialLoginButton(
                        context: context,
                        assetPath: 'assets/icons/facebook.png',
                        text: 'Tiếp tục với Facebook',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Facebook button pressed'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        context: context,
                        assetPath: 'assets/icons/google.png',
                        text: 'Tiếp tục với Google',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google button pressed'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SocialLoginButton(
                        context: context,
                        assetPath: 'assets/icons/apple.png',
                        text: 'Tiếp tục với Apple',
                        finalIconColor: isDark ? Colors.white : Colors.black,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Apple button pressed'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "hoặc",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sign in with password
                      botton(
                        context: context,
                        text: 'Đăng nhập với mật khẩu',
                        onPressed: () {
                          Navigator.pushNamed(context, '/loginwithpassword');
                        },
                      ),
                      const SizedBox(height: 24),
                      // Don't have an account section
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
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
