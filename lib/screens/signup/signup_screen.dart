import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/ElevatedButtonsocial.dart';
import 'package:lms/apps/utils/botton.dart';
import 'package:lms/apps/utils/customTextField.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
import 'package:lms/screens/signup/cubit/sign_up_cubit.dart';
import 'package:lms/services/auth_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
    final colorScheme = theme.colorScheme;

    return BlocProvider<SignUpCubit>(
      create:
          (_) => SignUpCubit(
            AuthService(FirebaseAuth.instance, FirebaseMessaging.instance),
          ),
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            _showSuccessDialog(context);
          }
        },
        child: BlocBuilder<SignUpCubit, SignUpState>(
          builder: (context, state) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary.withOpacity(isDark ? 0.18 : 0.10),
                      theme.scaffoldBackgroundColor,
                      colorScheme.primary.withOpacity(isDark ? 0.18 : 0.08),
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
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 154,
                              height: 154,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.secondary.withOpacity(
                                      0.22,
                                    ),
                                    blurRadius: 32,
                                    offset: const Offset(0, 18),
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
                                      (context, error, stackTrace) => Container(
                                        color: colorScheme.surface,
                                        child: Icon(
                                          Icons.person_add_alt_1,
                                          size: 78,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          Text(
                            'Tạo tài khoản học tập',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hoàn tất thông tin để lưu tiến độ học, nhận gợi ý khóa học và kết nối mentor.',
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
                          const SizedBox(height: 24),
                          Text(
                            'Hoặc đăng nhập bằng',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
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
                                  color: colorScheme.onSurfaceVariant,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
