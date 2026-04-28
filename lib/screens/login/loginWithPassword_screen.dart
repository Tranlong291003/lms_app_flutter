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
    final colorScheme = theme.colorScheme;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        _PasswordHeroIllustration(
                          assetPath:
                              isDark
                                  ? 'assets/images/login_dark.png'
                                  : 'assets/images/login_light.png',
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chào mừng bạn trở lại!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Đăng nhập để tiếp tục học, theo dõi tiến độ và luyện quiz.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(
                              isDark ? 0.88 : 0.96,
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
                              CustomTextField(
                                labelText: 'Email',
                                controller: _emailController,
                                prefixAsset: 'assets/icons/email.png',
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                labelText: 'Mật khẩu',
                                controller: _passwordController,
                                showVisibilityIcon: true,
                                obscureText: true,
                                prefixAsset: 'assets/icons/padlock.png',
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.forgotPassword,
                                    );
                                  },
                                  child: const Text('Quên mật khẩu?'),
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                  height: 54,
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
                        const SizedBox(height: 22),
                        Text(
                          'Hoặc đăng nhập bằng',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton(
                              width: 68,
                              context: context,
                              assetPath: 'assets/icons/facebook.png',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 14),
                            SocialLoginButton(
                              width: 68,
                              context: context,
                              assetPath: 'assets/icons/google.png',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 14),
                            SocialLoginButton(
                              width: 68,
                              context: context,
                              assetPath: 'assets/icons/apple.png',
                              finalIconColor:
                                  isDark ? Colors.white : Colors.black,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'Chưa có tài khoản? ',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRouter.signup);
                              },
                              child: const Text('Đăng ký'),
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
        );
      },
    );
  }
}

class _PasswordHeroIllustration extends StatelessWidget {
  const _PasswordHeroIllustration({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 144,
      height: 144,
      padding: const EdgeInsets.all(9),
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
            blurRadius: 30,
            offset: const Offset(0, 16),
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
                  Icons.lock_outline_rounded,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
              ),
        ),
      ),
    );
  }
}
