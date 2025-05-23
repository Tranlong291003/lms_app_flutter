import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/screens/login/loginWithPassword_screen.dart';
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
      emit(SignUpFailure(message: "Email không hợp lệ"));
      return;
    }
    if (!_arePasswordsValid(password, confirmPassword)) {
      emit(SignUpFailure(message: "Mật khẩu và mật khẩu xác nhận không khớp"));
      return;
    }
    if (!_isPhoneNumberValid(phone)) {
      emit(SignUpFailure(message: "Số điện thoại không hợp lệ"));
      return;
    }

    try {
      emit(SignUpLoading());

      await _authService.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      // Nếu đăng ký thành công, chuyển sang trạng thái thành công
      emit(SignUpSuccess());

      // Điều hướng về trang đăng nhập
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: LoginWithPasswordScreen(),
        ),
      );
    } catch (e) {
      // Xử lý lỗi khi gọi API
      emit(SignUpFailure(message: e.toString()));
    }
  }
}
