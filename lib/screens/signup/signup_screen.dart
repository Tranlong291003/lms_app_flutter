import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/signup/cubit/sign_up_cubit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  void _showSuccessDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Column(
              children: [
                Icon(Icons.check_circle, color: AppTheme.success, size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Đăng ký thành công!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              'Bạn đã đăng ký thành công. Hãy đăng nhập để bắt đầu học!',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pushReplacement(
                    context,
                    PageTransition(
                      type: PageTransitionType.fade,
                      child: LoginWithPasswordScreen(),
                    ),
                  );
                },
                child: const Text('Đăng nhập ngay'),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

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
    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            _showSuccessDialog(context);
          }
        },
        child: BlocBuilder<SignUpCubit, SignUpState>(
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
                                    ? 'assets/images/signup_dark.png'
                                    : 'assets/images/signup_light.png',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons.person_add_alt_1,
                                      size: 90,
                                      color: AppTheme.primary,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tạo tài khoản mới',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đăng ký để trải nghiệm đầy đủ các tính năng của hệ thống LMS',
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
                                    labelText: 'Họ và tên',
                                    controller: _nameController,
                                    prefixAsset: 'assets/icons/user.png',
                                  ),
                                  const SizedBox(height: 18),
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
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    labelText: 'Nhập lại mật khẩu',
                                    controller: _confirmPasswordController,
                                    showVisibilityIcon: true,
                                    obscureText: true,
                                    prefixAsset: 'assets/icons/padlock.png',
                                  ),
                                  const SizedBox(height: 18),
                                  CustomTextField(
                                    labelText: 'Số điện thoại',
                                    controller: _phoneController,
                                    prefixAsset: 'assets/icons/telephone.png',
                                  ),
                                  const SizedBox(height: 24),
                                  if (state is SignUpLoading)
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
                                      text: 'Đăng ký',
                                      onPressed: () {
                                        context.read<SignUpCubit>().signUp(
                                          context: context,
                                          name: _nameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          confirmPassword:
                                              _confirmPasswordController.text,
                                          phone: _phoneController.text,
                                        );
                                      },
                                    ),
                                  if (state is SignUpFailure)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        state.message,
                                        style: TextStyle(color: AppTheme.error),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                finalIconColor:
                                    isDark ? Colors.white : Colors.black,
                                width: 70,
                                context: context,
                                assetPath: 'assets/icons/apple.png',
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Đã có tài khoản?",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textSecondary,
                                ),
                              ),
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
                                child: Text(
                                  "Đăng nhập",
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
        ),
      ),
    );
  }
}
