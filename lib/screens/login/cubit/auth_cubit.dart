import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/screens/login/cubit/auth_state.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/services/base_service.dart';

/// Nguồn chân lý duy nhất cho phiên đăng nhập (uid, email, role).
///
/// `role` ở đây lấy từ `GET /api/auth/me` — request duy nhất lúc khởi động —
/// thay vì phụ thuộc `GET /api/users/:uid` như `UserBloc` (có thể thất bại và
/// làm mất tab Dashboard).
class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState());

  /// Đăng nhập. Trả về `null` nếu thành công, ngược lại là thông báo lỗi.
  Future<String?> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final response = await _authService.login(
        email: email,
        password: password,
        remember: remember,
      );

      // Token đã được AuthService lưu; ở đây cập nhật state phiên và bản sao
      // cục bộ cho các tầng không có BuildContext.
      final uid = _resolveUid(response);
      final role = _resolveRole(response);
      if (uid != null) {
        await BaseService.writeSession(uid: uid, role: role);
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: uid,
          email: _resolveEmail(response),
          role: role,
        ),
      );
      return null;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: message),
      );
      return message;
    }
  }

  /// Đăng ký. API trả token luôn nên vào thẳng app, không cần đăng nhập lại.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final response = await _authService.signUp(
        name: name,
        email: email,
        password: password,
      );

      final uid = _resolveUid(response);
      final role = _resolveRole(response);
      if (uid != null) {
        await BaseService.writeSession(uid: uid, role: role);
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: uid,
          email: _resolveEmail(response),
          role: role,
        ),
      );
      return null;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(
        state.copyWith(status: AuthStatus.error, errorMessage: message),
      );
      return message;
    }
  }

  String? _resolveUid(Map<String, dynamic> response) {
    final user = response['user'];
    if (user is Map && user['uid'] != null) return user['uid'].toString();
    return response['uid']?.toString() ?? response['user_id']?.toString();
  }

  String? _resolveEmail(Map<String, dynamic> response) {
    final user = response['user'];
    if (user is Map && user['email'] != null) return user['email'].toString();
    return response['email']?.toString();
  }

  String? _resolveRole(Map<String, dynamic> response) {
    final user = response['user'];
    if (user is Map && user['role'] != null) return user['role'].toString();
    return response['role']?.toString();
  }

  Future<void> logout() async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      await _authService.logout();
      // AuthState.copyWith dùng `??` nên không xoá được field cũ; phát state mới
      // để chắc chắn uid/email/role đều rỗng.
      emit(const AuthState(status: AuthStatus.unauthenticated));
      print('[INFO] Logout completed successfully');
    } catch (e) {
      print('[ERR] Failed to logout: $e');
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  /// Khôi phục phiên khi mở lại app.
  ///
  /// Có token → gọi `/api/auth/me` để lấy hồ sơ + role hiện tại trong DB.
  /// 401 (sau khi BaseService đã thử refresh) → hết phiên thật.
  ///
  /// `force = false` (mặc định): nếu đã xác thực rồi thì bỏ qua, tránh gọi lại
  /// `/me` mỗi lần `AppEntryGate` rebuild.
  Future<void> checkAuthStatus({bool force = false}) async {
    if (!force &&
        state.status == AuthStatus.authenticated &&
        state.userId != null) {
      return;
    }

    try {
      emit(state.copyWith(status: AuthStatus.loading));

      final token = await _authService.getToken();
      if (token == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final userInfo = await _authService.getUserInfo();
      final uid = userInfo['uid']?.toString();
      final role = userInfo['role']?.toString();
      if (uid != null) {
        await BaseService.writeSession(uid: uid, role: role);
      }
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          userId: uid,
          email: userInfo['email']?.toString(),
          role: role,
        ),
      );
    } catch (e) {
      // Hết phiên: BaseService đã thử refresh trước khi ném lỗi.
      print('[INFO] Không khôi phục được phiên: $e');
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }
}
