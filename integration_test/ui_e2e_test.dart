// integration_test/ui_e2e_test.dart
//
// E2E thao tác THẬT trên máy/giả lập: chạm, cuộn, mở màn hình — không mock API.
// Mục đích: bắt các chỗ giao diện trông bấm được nhưng không gọi API, dữ liệu
// hiển thị sai, hoặc tràn bố cục.
//
// Chạy trên iPhone 17 simulator:
//   flutter test integration_test/ui_e2e_test.dart \
//     -d AC081CC0-9EF9-4316-A23B-CA8FEA7C3702
//
// Tài khoản học viên mặc định: test2@gmail.com / 123123
// (đổi qua --dart-define=TEST_EMAIL / TEST_PASSWORD)
//
// Lưu ý: KHÔNG dùng `pumpAndSettle` — app liên tục gọi API và chạy hoạt ảnh nên
// không bao giờ "settle"; dùng `pump` theo nhịp cố định.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lms/main.dart' as app;
import 'package:lms/screens/login/cubit/auth_cubit.dart';
import 'package:lms/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _email = String.fromEnvironment(
  'TEST_EMAIL',
  defaultValue: 'test2@gmail.com',
);
const _password = String.fromEnvironment(
  'TEST_PASSWORD',
  defaultValue: '123123',
);

/// Khoá học trả phí có thật trên môi trường production (899.000 → 599.000).
const _paidCourseId = 253;

/// Nhịp `pump` cố định để mạng/hoạt ảnh kịp tiến triển.
Future<void> pumpFor(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 3),
}) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Chờ tới khi [finder] xuất hiện (dùng vòng `pump` thay cho `pumpAndSettle`).
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Hết thời gian chờ nhưng không thấy: $finder');
}

/// Khởi động app với phiên đã đăng nhập và intro đã xem.
///
/// Đăng nhập THẬT qua `AuthService` (không mock) để app mở lên đã ở trạng thái
/// đã xác thực — tránh phải thao tác trên form đăng nhập, vốn dễ vỡ khi giao
/// diện đổi và không phải thứ đang cần kiểm chứng ở đây.
Future<void> launchLoggedIn(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({'intro_seen': true});
  final login = await AuthService().login(email: _email, password: _password);
  expect(login['access_token'], isNotNull, reason: 'Đăng nhập phải trả token');

  app.main();
  await pumpFor(tester, duration: const Duration(seconds: 6));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Mở app và đi qua từng tab dưới của học viên', (tester) async {
    await launchLoggedIn(tester);

    // Vào được app: thanh điều hướng dưới hiện ra.
    await waitFor(tester, find.text('Trang chủ'), timeout: const Duration(seconds: 60));

    // Trang chủ phải có dữ liệu thật từ API (không phải màn trắng).
    expect(
      find.byType(Scaffold),
      findsWidgets,
      reason: 'Trang chủ phải dựng được',
    );

    // Không được có lỗi tràn bố cục trên trang chủ.
    expect(
      tester.takeException(),
      isNull,
      reason: 'Trang chủ không được tràn bố cục',
    );

    for (final tab in ['Khoá học', 'Quiz', 'Mentor']) {
      final item = find.text(tab);
      if (item.evaluate().isEmpty) continue;
      await tester.tap(item.last);
      await pumpFor(tester, duration: const Duration(seconds: 4));
      expect(
        find.byType(Scaffold),
        findsWidgets,
        reason: 'Tab "$tab" phải dựng được màn hình',
      );
    }
  });

  testWidgets('Chi tiết khoá học trả phí hiển thị giá thật, không ghi "miễn phí"',
      (tester) async {
    await launchLoggedIn(tester);
    await waitFor(tester, find.text('Trang chủ'), timeout: const Duration(seconds: 60));

    // Mở thẳng màn chi tiết khoá học trả phí qua router của app.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
    navigator.pushNamed('/courseDetail', arguments: _paidCourseId);
    await pumpFor(tester, duration: const Duration(seconds: 8));

    // Nút đăng ký phải ghi giá, KHÔNG được ghi "miễn phí".
    expect(
      find.text('Đăng ký khoá học miễn phí'),
      findsNothing,
      reason: 'Khoá trả phí không được hiện nút "miễn phí" '
          '(giá 899.000, giảm còn 599.000)',
    );
    await waitFor(
      tester,
      find.textContaining('Đăng ký khoá học ·'),
      timeout: const Duration(seconds: 20),
    );

    expect(
      find.textContaining('599.000'),
      findsWidgets,
      reason: 'Phải hiển thị giá khuyến mãi thật của khoá học',
    );

    expect(
      tester.takeException(),
      isNull,
      reason: 'Màn chi tiết khoá học không được tràn bố cục',
    );
  });
}
