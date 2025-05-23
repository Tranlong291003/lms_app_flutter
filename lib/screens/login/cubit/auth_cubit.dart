import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/screens/login/cubit/auth_state.dart';
import 'package:lms/services/auth_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState());

  Future<void> login(String email, String password) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        // Lưu token từ response
        final token = response['token'] as String;
        await _authService.setToken(token);

        // Lưu thông tin user
        final userId = response['user_id'] as String;
        final userEmail = response['email'] as String;
        final userRole = response['role'] as String;

        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            userId: userId,
            email: userEmail,
            role: userRole,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                response['message'] as String? ?? 'Đăng nhập thất bại',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // Gọi logout từ service
      await _authService.logout();

      // Xóa token và thông tin user
      await _authService.clearToken();

      // Cập nhật state
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          userId: null,
          email: null,
          role: null,
        ),
      );

      print('[INFO] Logout completed successfully');
    } catch (e) {
      print('[ERR] Failed to logout: $e');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      // Kiểm tra token
      final token = await _authService.getToken();

      if (token != null) {
        // Token tồn tại, lấy thông tin user
        final userInfo = await _authService.getUserInfo();
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            userId: userInfo['user_id'],
            email: userInfo['email'],
            role: userInfo['role'],
          ),
        );
      } else {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      }
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
