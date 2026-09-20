// test/auth_migration_test.dart
//
// Kiểm thử tích hợp THẬT cho luồng xác thực mới của API (không còn Firebase Auth).
// Dùng chính `AuthService` / `BaseService` của app, chống lại API đang chạy.
//
// Chạy:
//   flutter test test/auth_migration_test.dart
//
// Mặc định trỏ về http://localhost:4100 (API local). Đổi bằng:
//   flutter test --dart-define=API_BASE_URL=https://online-learning-api.vercel.app
//
// Phần refresh-token cần API thật vì phụ thuộc bảng refresh_tokens.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/api_config.dart';
import 'package:lms/services/auth_service.dart';
import 'package:lms/services/base_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // `flutter_test` chặn mọi HTTP request thật bằng mock trả 400.
  HttpOverrides.global = null;

  final stamp = DateTime.now().millisecondsSinceEpoch;
  final email = 'flutter.auth.$stamp@example.com';
  const password = 'Test123456!';
  const newPassword = 'NewPass123456!';

  late AuthService auth;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Không truyền FirebaseMessaging: trong test Firebase chưa được khởi tạo.
    // AuthService bỏ qua FCM token và vẫn đăng nhập bình thường.
    auth = AuthService();
  });

  tearDownAll(() async {
    await BaseService.removeTokens();
  });

  group('Đăng ký (POST /api/auth/register)', () {
    test('trả access_token + refresh_token và lưu vào máy', () async {
      final data = await auth.signUp(
        name: 'Flutter Auth Test',
        email: email,
        password: password,
      );

      expect(data['access_token'], isNotNull);
      expect(data['refresh_token'], isNotNull);
      expect(data['user'], isNotNull);

      // Token phải được lưu cục bộ để request sau dùng ngay.
      expect(await auth.getToken(), isNotNull);
      expect(await auth.getRefreshToken(), isNotNull);
    });

    test('trùng email → lỗi "đã được đăng ký"', () async {
      await expectLater(
        auth.signUp(name: 'Trùng', email: email, password: password),
        throwsA(
          predicate(
            (e) => e.toString().contains('đã được đăng ký'),
            'thông báo phải nói email đã được đăng ký',
          ),
        ),
      );
    });

    test('mật khẩu quá ngắn → lỗi từ API', () async {
      await expectLater(
        auth.signUp(
          name: 'Yếu',
          email: 'weak.$stamp@example.com',
          password: '123',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Hồ sơ (GET /api/auth/me)', () {
    test('trả uid/email/role của chính mình', () async {
      final user = await auth.getUserInfo();
      expect(user['uid'], isNotNull);
      expect(user['email'], email);
      expect(user['role'], 'user');
    });
  });

  group('Đăng nhập (POST /api/auth/login)', () {
    test('sai mật khẩu → thông báo gộp, không lộ email có tồn tại hay không',
        () async {
      await expectLater(
        auth.login(email: email, password: 'SaiMatKhau123!'),
        throwsA(
          predicate(
            (e) => e.toString().contains('Email hoặc mật khẩu không đúng'),
            'không được phân biệt email sai và mật khẩu sai',
          ),
        ),
      );
    });

    test('email không tồn tại → cùng thông báo như sai mật khẩu', () async {
      await expectLater(
        auth.login(email: 'khong.ton.tai.$stamp@example.com', password: password),
        throwsA(
          predicate((e) => e.toString().contains('Email hoặc mật khẩu không đúng')),
        ),
      );
    });

    test('đúng thông tin → có token', () async {
      final data = await auth.login(email: email, password: password);
      expect(data['access_token'], isNotNull);
      expect(data['refresh_token'], isNotNull);
    });

    test('remember=true → vẫn đăng nhập được', () async {
      final data = await auth.login(
        email: email,
        password: password,
        remember: true,
      );
      expect(data['access_token'], isNotNull);
    });
  });

  group('Tự động làm mới access token khi 401', () {
    test('401 TOKEN_EXPIRED → BaseService tự refresh và phát lại request',
        () async {
      // Mô phỏng access token đã hết hạn bằng một JWT rác: server trả 401.
      // Interceptor phải gọi /api/auth/refresh rồi phát lại request thành công.
      await auth.setToken('token.gia.het.han');

      final response = await auth.get(ApiConfig.authMe);

      expect(
        response.statusCode,
        200,
        reason: 'Sau khi refresh phải phát lại được request /me',
      );

      // Access token mới phải khác token rác ban đầu.
      final current = await auth.getToken();
      expect(current, isNot('token.gia.het.han'));
    });

    test('refresh token bị rotate: token mới khác token cũ', () async {
      final before = await auth.getRefreshToken();

      // Ép một lần refresh bằng cách đặt access token rác.
      await auth.setToken('token.gia.het.han.2');
      await auth.get(ApiConfig.authMe);

      final after = await auth.getRefreshToken();
      expect(
        after,
        isNotNull,
        reason: 'Phải lưu refresh token mới sau khi rotate',
      );
      expect(
        after,
        isNot(before),
        reason:
            'Refresh token phải được rotate — nếu giữ token cũ thì lần refresh '
            'sau sẽ bị coi là token bị đánh cắp và thu hồi cả phiên',
      );
    });

    test('gọi nhiều request song song khi hết hạn → chỉ refresh MỘT lần',
        () async {
      // Nếu refresh chạy song song, các lần sau dùng lại token đã rotate và
      // server sẽ thu hồi cả phiên (SESSION_REVOKED) -> test này sẽ fail.
      await auth.setToken('token.gia.het.han.3');

      final responses = await Future.wait([
        auth.get(ApiConfig.authMe),
        auth.get(ApiConfig.authMe),
        auth.get(ApiConfig.authMe),
        auth.get(ApiConfig.authMe),
        auth.get(ApiConfig.authMe),
      ]);

      for (final r in responses) {
        expect(r.statusCode, 200);
      }

      // Phiên vẫn dùng được sau khi refresh đồng thời.
      final stillWorks = await auth.get(ApiConfig.authMe);
      expect(stillWorks.statusCode, 200);
      expect(stillWorks.data['user']['email'], email);
    });

    test('refresh token hỏng → request thất bại (để app đăng xuất)', () async {
      final goodRefresh = await auth.getRefreshToken();
      await auth.saveRefreshToken('refresh-token-khong-hop-le');
      await auth.setToken('token.gia.het.han.4');

      await expectLater(
        auth.get(ApiConfig.authMe),
        throwsA(isA<DioException>()),
      );

      // Khôi phục lại cho các test sau.
      await auth.saveRefreshToken(goodRefresh!);
    });
  });

  group('Đăng xuất (POST /api/auth/logout)', () {
    test('thu hồi refresh token ở server và xoá token cục bộ', () async {
      // Đăng nhập lại để có phiên sạch.
      await auth.login(email: email, password: password);
      final refreshBefore = await auth.getRefreshToken();
      expect(refreshBefore, isNotNull);

      await auth.logout();

      expect(await auth.getToken(), isNull);
      expect(await auth.getRefreshToken(), isNull);

      // Refresh token cũ đã bị thu hồi -> dùng lại phải thất bại.
      final reuse = await Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          // 401 là kết quả MONG ĐỢI ở đây, nên phải tắt việc ném lỗi theo status.
          validateStatus: (_) => true,
        ),
      ).post(ApiConfig.authRefresh, data: {'refresh_token': refreshBefore});
      expect(reuse.statusCode, 401);
    });

    test('logout khi không có token vẫn không ném lỗi', () async {
      await auth.logout();
    });
  });

  group('Đổi mật khẩu (POST /api/auth/change-password)', () {
    test('mật khẩu hiện tại sai → lỗi', () async {
      await auth.login(email: email, password: password);
      await expectLater(
        auth.changePassword(
          currentPassword: 'SaiHoanToan123!',
          newPassword: newPassword,
        ),
        throwsA(predicate((e) => e.toString().contains('không đúng'))),
      );
    });

    test('đổi thành công → thu hồi phiên, mật khẩu cũ không dùng được',
        () async {
      await auth.login(email: email, password: password);
      await auth.changePassword(
        currentPassword: password,
        newPassword: newPassword,
      );

      // Server thu hồi mọi phiên -> token cục bộ đã bị xoá.
      expect(await auth.getToken(), isNull);

      // Mật khẩu cũ không còn hiệu lực.
      await expectLater(
        auth.login(email: email, password: password),
        throwsA(
          predicate((e) => e.toString().contains('Email hoặc mật khẩu không đúng')),
        ),
      );

      // Mật khẩu mới đăng nhập được.
      final ok = await auth.login(email: email, password: newPassword);
      expect(ok['access_token'], isNotNull);
    });
  });

  group('Quên / đặt lại mật khẩu', () {
    test('forgot-password luôn trả thông điệp chung (không dò email)', () async {
      // Email tồn tại và email không tồn tại đều không được ném lỗi.
      await auth.forgotPassword(email);
      await auth.forgotPassword('khong.ton.tai.$stamp@example.com');
    });

    test('reset-password với token sai → lỗi', () async {
      await expectLater(
        auth.resetPassword(token: 'token-sai', newPassword: password),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ApiConfig', () {
    test('các endpoint auth trỏ đúng /api/auth/*', () {
      expect(ApiConfig.authLogin, endsWith('/api/auth/login'));
      expect(ApiConfig.authRegister, endsWith('/api/auth/register'));
      expect(ApiConfig.authRefresh, endsWith('/api/auth/refresh'));
      expect(ApiConfig.authMe, endsWith('/api/auth/me'));
      expect(ApiConfig.authLogout, endsWith('/api/auth/logout'));
      expect(ApiConfig.authChangePassword, endsWith('/api/auth/change-password'));
      expect(ApiConfig.authForgotPassword, endsWith('/api/auth/forgot-password'));
      expect(ApiConfig.authResetPassword, endsWith('/api/auth/reset-password'));
    });
  });
}
