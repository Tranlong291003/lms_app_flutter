import 'dart:convert';

import 'package:dio/dio.dart'; // Import Dio
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Dio dio; // Khởi tạo Dio

  // Khởi tạo Dio trong constructor
  LoginBloc({required this.dio}) : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading(); // Đang tải

      try {
        // Đăng nhập với Firebase và lấy idToken
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: event.email,
              password: event.password,
            );

        String? idToken = await userCredential.user?.getIdToken();
        if (idToken == null) {
          yield LoginFailure(errorMessage: 'Không thể lấy idToken từ Firebase');
          return;
        }

        // Sử dụng Dio để gửi idToken tới API để xác thực
        final response = await dio.post(
          'https://api.example.com/api/users/login', // Thay bằng endpoint thực tế của bạn
          data: json.encode({'idToken': idToken}),
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 200) {
          yield LoginSuccess(idToken: idToken); // Đăng nhập thành công
        } else {
          yield LoginFailure(errorMessage: 'Xác thực với API thất bại');
        }
      } catch (e) {
        yield LoginFailure(errorMessage: 'Lỗi đăng nhập: $e');
      }
    }
  }
}
