import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:lms/services/base_service.dart';

/// Xác thực với API tự quản lý tài khoản.
///
/// Luồng: `POST /api/auth/login { email, password }` → `access_token` (15 phút)
/// + `refresh_token` (30/90 ngày). Không còn Firebase Auth; `firebase_messaging`
/// chỉ còn dùng để lấy FCM token cho push notification.
class AuthService extends BaseService {
  /// Có thể null khi Firebase chưa được cấu hình (ví dụ iOS chưa có
  /// `GoogleService-Info.plist`) — khi đó chỉ bỏ qua FCM token, không chặn
  /// đăng nhập.
  final FirebaseMessaging? _firebaseMessaging;

  AuthService([this._firebaseMessaging]) : super();

  /// Lấy FCM token, không để lỗi chặn đăng nhập.
  ///
  /// Firebase có thể chưa được khởi tạo (`FirebaseMessaging.instance` ném lỗi
  /// ngay khi truy cập), hoặc `getToken()` thất bại trên simulator. Push
  /// notification là tính năng phụ nên mọi lỗi ở đây đều bỏ qua.
  Future<String?> _getFcmToken() async {
    try {
      final messaging = _firebaseMessaging ?? FirebaseMessaging.instance;
      return await messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Đăng nhập bằng email + mật khẩu do API quản lý.
  ///
  /// [remember] = true → refresh token sống 90 ngày thay vì 30.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    try {
      final fcmToken = await _getFcmToken();

      final response = await post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
          'fcmToken': fcmToken,
          'remember': remember,
        },
      );

      if (response.statusCode != 200 || response.data is! Map) {
        throw Exception('Đăng nhập thất bại (${response.statusCode})');
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      await _persistSession(data);
      return data;
    } catch (e) {
      throw Exception(_friendlyLoginError(e));
    }
  }

  /// Đăng ký tài khoản mới.
  ///
  /// API trả token luôn nên **không cần** đăng nhập lại sau khi đăng ký.
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final fcmToken = await _getFcmToken();
      final response = await post(
        ApiConfig.authRegister,
        data: {
          'email': email,
          'password': password,
          'name': name,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Đăng ký thất bại (${response.statusCode})');
      }

      final data = Map<String, dynamic>.from(response.data as Map);
      await _persistSession(data);
      return data;
    } catch (e) {
      throw Exception(_friendlySignUpError(e));
    }
  }

  /// Lưu access token + refresh token sau khi đăng nhập/đăng ký.
  Future<void> _persistSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] ?? data['token'];
    final refreshToken = data['refresh_token'];

    if (accessToken is! String || accessToken.isEmpty) {
      throw Exception('Máy chủ không trả về token đăng nhập');
    }

    await setToken(accessToken);
    if (refreshToken is String && refreshToken.isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }

  /// Hồ sơ của người đang đăng nhập (`GET /api/auth/me`).
  ///
  /// Dùng để khôi phục phiên lúc mở app: 200 → vào app với role hiện tại trong
  /// DB; 401 → BaseService lo refresh, thất bại thì về màn đăng nhập.
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await get(ApiConfig.authMe);
      final data = response.data;
      if (data is Map && data['user'] is Map) {
        return Map<String, dynamic>.from(data['user'] as Map);
      }
      throw Exception('Không thể lấy thông tin người dùng');
    } catch (e) {
      throw Exception(
        'Không thể lấy thông tin người dùng: ${extractApiError(e, fallback: '$e')}',
      );
    }
  }

  /// Đăng xuất: thu hồi refresh token ở server trước, rồi xoá token local.
  ///
  /// Mất mạng **không** được chặn việc đăng xuất ở phía app.
  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        await post(ApiConfig.authLogout, data: {'refresh_token': refreshToken});
      }
    } catch (_) {
      // Bỏ qua: vẫn phải xoá phiên cục bộ.
    } finally {
      await clearToken();
    }
  }

  Future<void> logoutWithContext(BuildContext context) async {
    try {
      await logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
      }
    }
  }

  /// Đổi mật khẩu. Server thu hồi mọi phiên nên phải đăng xuất ở phía app.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await post(
        ApiConfig.authChangePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      // Server đã thu hồi mọi refresh token -> xoá phiên cục bộ.
      await clearToken();
    } catch (e) {
      throw Exception(
        extractApiError(e, fallback: 'Đổi mật khẩu thất bại'),
      );
    }
  }

  /// Yêu cầu đặt lại mật khẩu qua email.
  Future<void> forgotPassword(String email) async {
    try {
      await post(ApiConfig.authForgotPassword, data: {'email': email});
    } catch (e) {
      throw Exception(
        extractApiError(e, fallback: 'Không gửi được yêu cầu đặt lại mật khẩu'),
      );
    }
  }

  /// Đặt lại mật khẩu bằng token nhận từ email.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await post(
        ApiConfig.authResetPassword,
        data: {'token': token, 'new_password': newPassword},
      );
    } catch (e) {
      throw Exception(
        extractApiError(e, fallback: 'Đặt lại mật khẩu thất bại'),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Thông điệp lỗi thân thiện
  // ---------------------------------------------------------------------------

  String _friendlyLoginError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final code = extractApiErrorCode(error);
      final message = extractApiError(error, fallback: '');

      if (code == ApiErrorCode.accountLocked) {
        return message.isNotEmpty
            ? message
            : 'Tài khoản tạm bị khoá do đăng nhập sai nhiều lần';
      }
      if (status == 403) {
        return message.isNotEmpty ? message : 'Tài khoản đã bị khoá';
      }
      if (status == 401) {
        // Không phân biệt email sai hay mật khẩu sai (server cố tình gộp).
        return message.isNotEmpty
            ? message
            : 'Email hoặc mật khẩu không đúng';
      }
      if (status == 429) {
        return message.isNotEmpty
            ? message
            : 'Bạn đã thử quá nhiều lần, vui lòng thử lại sau';
      }
      if (message.isNotEmpty) return message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _friendlySignUpError(Object error) {
    if (error is DioException) {
      final message = extractApiError(error, fallback: '');
      if (message.isNotEmpty) return message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
