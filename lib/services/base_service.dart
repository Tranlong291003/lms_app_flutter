// lib/services/base_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp cơ sở cho mọi service gọi API.
///
/// Nhiệm vụ chính ngoài việc bọc các HTTP method:
/// - Gắn `Authorization: Bearer <access_token>` vào mọi request.
/// - **Tự động làm mới access token khi gặp 401** rồi phát lại request cũ.
///   Access token chỉ sống 15 phút nên nếu không có bước này người dùng sẽ bị
///   đá về màn đăng nhập liên tục.
class BaseService {
  final Dio _dio;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _uidKey = 'auth_uid';
  static const String _roleKey = 'auth_role';

  /// Cờ đánh dấu request đã được phát lại sau khi refresh (chống lặp vô hạn).
  static const String _retriedFlag = 'auth_retried';

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static bool _isHandlingTokenError = false;

  /// Future dùng chung cho việc refresh.
  ///
  /// Nhiều request cùng nhận 401 thì chỉ được refresh **một lần**: mỗi lần gọi
  /// `/api/auth/refresh` server sẽ rotate refresh token và vô hiệu hoá token cũ,
  /// nên gọi song song sẽ khiến các lần sau bị coi là dùng lại token cũ (dấu hiệu
  /// bị đánh cắp) và **thu hồi cả phiên**.
  static Future<bool>? _refreshInFlight;

  /// Các endpoint công khai/không dùng access token của phiên.
  ///
  /// 401 ở những endpoint này là lỗi nghiệp vụ (sai mật khẩu, token hết hạn...),
  /// không phải "access token của phiên đã hết hạn" — nếu hiểu nhầm sẽ vừa gọi
  /// refresh vô ích vừa đá người dùng ra khỏi chính màn đăng nhập.
  static const List<String> _authEndpoints = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/forgot-password',
    '/api/auth/reset-password',
  ];

  BaseService({String? token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      ) {
    _setupInterceptors();
    _initTokenFromPrefs();
  }

  // ---------------------------------------------------------------------------
  // Lưu trữ token
  // ---------------------------------------------------------------------------

  static Future<String?> readToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('[ERR] Failed to read token: $e');
      return null;
    }
  }

  static Future<void> writeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> readRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('[ERR] Failed to read refresh token: $e');
      return null;
    }
  }

  /// Lưu refresh token. **Bắt buộc** gọi sau mỗi lần `/api/auth/refresh` vì
  /// server đã rotate và vô hiệu hoá token cũ.
  static Future<void> writeRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  static Future<void> removeTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_roleKey);
  }

  // ---------------------------------------------------------------------------
  // Phiên đăng nhập (uid/role) lưu cục bộ
  // ---------------------------------------------------------------------------

  /// Lưu uid/role của phiên để tầng repository/service có thể đọc mà không cần
  /// `BuildContext`. `AuthCubit` là nguồn chân lý cho UI; đây chỉ là bản sao
  /// dùng ở nơi không có context.
  static Future<void> writeSession({required String uid, String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, uid);
    if (role != null) {
      await prefs.setString(_roleKey, role);
    }
  }

  static Future<String?> readSessionUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_uidKey);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> readSessionRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_roleKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _initTokenFromPrefs() async {
    try {
      final token = await readToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('[ERR] Failed to load token: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Interceptor
  // ---------------------------------------------------------------------------

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Request multipart phải để Dio tự sinh header kèm `boundary`.
          final isMultipart = options.data is FormData;
          if (isMultipart) {
            options.headers.remove(Headers.contentTypeHeader);
            options.contentType = null;
          } else if (options.data != null &&
              !options.headers.containsKey(Headers.contentTypeHeader)) {
            options.headers[Headers.contentTypeHeader] =
                Headers.jsonContentType;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (DioException e, handler) async {
          final path = e.requestOptions.path;
          final isAuthEndpoint = _authEndpoints.any(path.contains);

          if (e.response?.statusCode == 401 && !isAuthEndpoint) {
            // Đánh dấu request đã được phát lại một lần.
            //
            // Cần thiết vì request phát lại vẫn đi qua interceptor này: nếu 401
            // không phải do token hết hạn (ví dụ "mật khẩu hiện tại không đúng"
            // ở /api/auth/change-password) thì mỗi lần phát lại sẽ lại kích hoạt
            // refresh → phát lại → 401... lặp vô hạn cho tới khi hết timeout.
            final alreadyRetried =
                e.requestOptions.extra[_retriedFlag] == true;

            if (!alreadyRetried) {
              final refreshed = await _tryRefreshToken();
              if (refreshed) {
                final newToken = await readToken();
                final retryOptions = e.requestOptions;
                if (newToken != null) {
                  // Header của request cũ vẫn giữ token cũ, phải ghi đè trước
                  // khi phát lại nếu không sẽ 401 lần nữa.
                  retryOptions.headers['Authorization'] = 'Bearer $newToken';
                }
                retryOptions.extra[_retriedFlag] = true;
                try {
                  final retried = await _dio.fetch(retryOptions);
                  return handler.resolve(retried);
                } catch (_) {
                  // Phát lại vẫn lỗi -> rơi xuống xử lý đăng xuất bên dưới.
                }
              }
            }

            await handleTokenError();
            return handler.reject(e);
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Làm mới access token, chỉ chạy một lần cho dù nhiều request cùng 401.
  static Future<bool> _tryRefreshToken() {
    return _refreshInFlight ??= _doRefresh()
        .whenComplete(() => _refreshInFlight = null);
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = await readRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Dùng Dio RIÊNG, không đi qua interceptor này — nếu dùng chung `_dio`,
      // request refresh gặp 401 sẽ lại kích hoạt refresh và đệ quy vô hạn.
      final response = await Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      ).post(ApiConfig.authRefresh, data: {'refresh_token': refreshToken});

      final data = response.data;
      if (data is! Map) return false;

      final accessToken = data['access_token'] ?? data['token'];
      final newRefreshToken = data['refresh_token'];
      if (accessToken is! String) return false;

      await writeToken(accessToken);

      // BẮT BUỘC: refresh token đã bị rotate ở server, phải lưu bản mới.
      if (newRefreshToken is String) {
        await writeRefreshToken(newRefreshToken);
      }
      return true;
    } catch (e) {
      // Refresh token hết hạn / bị thu hồi / mất mạng -> coi như hết phiên.
      print('[ERR] Refresh token thất bại: $e');
      return false;
    }
  }

  /// Xoá token và đưa người dùng về màn đăng nhập.
  Future<void> handleTokenError() async {
    if (_isHandlingTokenError) return;

    try {
      _isHandlingTokenError = true;
      await clearToken();

      final context = navigatorKey.currentContext;
      if (context != null) {
        await context.read<AuthCubit>().logout();
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            context.read<AuthCubit>().logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('[ERR] Failed to handle token error: $e');
    } finally {
      _isHandlingTokenError = false;
    }
  }

  // ---------------------------------------------------------------------------
  // API token (instance) — AuthService có thể override nếu cần
  // ---------------------------------------------------------------------------

  Future<String?> getToken() => readToken();

  Future<void> setToken(String token) async {
    await writeToken(token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<String?> getRefreshToken() => readRefreshToken();

  Future<void> saveRefreshToken(String token) => writeRefreshToken(token);

  Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  Future<void> clearToken() async {
    try {
      await removeTokens();
      _dio.options.headers.remove('Authorization');
    } catch (e) {
      print('[ERR] Failed to clear token: $e');
    }
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );
}

/// Trích thông điệp lỗi từ response của API.
///
/// Backend dùng `{ error }` ở đa số endpoint và `{ message }` ở một số endpoint
/// cũ, nên cần đọc cả hai trước khi rơi về thông điệp mặc định.
String extractApiError(Object? error, {String fallback = 'Đã xảy ra lỗi'}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['error'] ?? data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Không kết nối được máy chủ, vui lòng kiểm tra mạng';
    }
    return error.message ?? fallback;
  }
  return fallback;
}

/// Mã lỗi xác thực do API trả về trong trường `code`.
class ApiErrorCode {
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String refreshTokenExpired = 'REFRESH_TOKEN_EXPIRED';
  static const String sessionRevoked = 'SESSION_REVOKED';
  static const String accountLocked = 'ACCOUNT_LOCKED';
}

/// Đọc `code` từ response lỗi (nếu có).
String? extractApiErrorCode(Object? error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['code'] != null) {
      return data['code'].toString();
    }
  }
  return null;
}
