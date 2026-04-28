import 'package:flutter/material.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/screens/signup/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(isDark ? 0.20 : 0.10),
              theme.scaffoldBackgroundColor,
              colorScheme.secondary.withOpacity(isDark ? 0.14 : 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  children: [
                    _AuthHeroIllustration(
                      assetPath:
                          isDark
                              ? 'assets/images/login_dark.png'
                              : 'assets/images/login_light.png',
                      fallbackIcon: Icons.school_rounded,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Học thông minh hơn cùng LMS',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Khám phá khóa học, mentor và quiz được cá nhân hóa cho hành trình của bạn.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(
                          isDark ? 0.86 : 0.96,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(
                              isDark ? 0.18 : 0.10,
                            ),
                            blurRadius: 32,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
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
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
                          SocialLoginButton(
                            context: context,
                            assetPath: 'assets/icons/apple.png',
                            text: 'Tiếp tục với Apple',
                            finalIconColor:
                                isDark ? Colors.white : Colors.black,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Apple button pressed'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          _DividerLabel(label: 'hoặc đăng nhập nhanh'),
                          const SizedBox(height: 20),
                          botton(
                            context: context,
                            text: 'Đăng nhập với mật khẩu',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRouter.loginWithPassword,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Chưa có tài khoản? ",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
                          child: const Text("Đăng ký"),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
      ],
    );
  }
}

class _AuthHeroIllustration extends StatelessWidget {
  const _AuthHeroIllustration({
    required this.assetPath,
    required this.fallbackIcon,
  });

  final String assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 168,
      height: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.22),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) => Container(
                color: theme.colorScheme.surface,
                child: Icon(
                  fallbackIcon,
                  size: 84,
                  color: theme.colorScheme.primary,
                ),
              ),
        ),
      ),
    );
  }
}
