import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/app_router.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/services/auth_service.dart';
import 'package:page_transition/page_transition.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthService _authService;

  SignUpCubit(this._authService) : super(SignUpInitial());

  // Kiểm tra số điện thoại hợp lệ
  bool _isPhoneNumberValid(String phone) {
    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegExp.hasMatch(phone);
  }

  // Kiểm tra email hợp lệ
  bool _isEmailValid(String email) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  // Kiểm tra mật khẩu và mật khẩu xác nhận
  bool _arePasswordsValid(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // Thực hiện đăng ký
  Future<void> signUp({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
  }) async {
    if (!_isEmailValid(email)) {
      emit(SignUpFailure(message: 'Email không hợp lệ'));
      return;
    }
    if (!_arePasswordsValid(password, confirmPassword)) {
      emit(SignUpFailure(message: 'Mật khẩu và mật khẩu xác nhận không khớp'));
      return;
    }
    // Số điện thoại là tùy chọn — chỉ kiểm tra khi người dùng có nhập.
    if (phone.trim().isNotEmpty && !_isPhoneNumberValid(phone.trim())) {
      emit(SignUpFailure(message: 'Số điện thoại không hợp lệ'));
      return;
    }

    try {
      emit(SignUpLoading());

      // `POST /api/auth/register` trả token luôn -> đăng ký qua AuthCubit để
      // phiên (uid/role) được thiết lập ngay, không cần đăng nhập lại.
      final message = await context.read<AuthCubit>().signUp(
        name: name,
        email: email,
        password: password,
      );

      if (message != null) {
        emit(SignUpFailure(message: message));
        return;
      }

      emit(SignUpSuccess());

      // Đã có phiên -> về cổng vào app để vào thẳng trang chủ.
      Navigator.pushNamedAndRemoveUntil(context, AppRouter.home, (r) => false);
    } catch (e) {
      emit(SignUpFailure(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
