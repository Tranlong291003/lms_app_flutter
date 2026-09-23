// test/stat_grid_layout_test.dart
//
// Lưới thống kê của dashboard admin/mentor KHÔNG thể kiểm bằng cách dựng màn
// hình trong test: `AppStatsCubit` luôn lỗi (không có mạng) nên lưới không bao
// giờ được dựng và lỗi tràn thật sẽ lọt qua.
//
// File này dựng thẳng widget dùng chung `StatGrid` — chính widget mà hai
// dashboard đang dùng — ở nhiều kích thước và cỡ chữ.
//
// Lỗi đã từng có: `childAspectRatio: 1.2` cố định làm ô cao ~115px trên máy
// 320px trong khi nội dung cần ~200px → tràn hẳn ra ngoài.
//
// Chạy: flutter test test/stat_grid_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/stat_grid.dart';

const _sizes = <String, Size>{
  'máy nhỏ 320x568': Size(320, 568),
  'phổ thông 390x844': Size(390, 844),
  'tablet 820x1180': Size(820, 1180),
};

/// Cỡ chữ hệ thống: mặc định, "Lớn", và mức tối đa thường gặp.
const _scales = <double>[1.0, 1.3, 1.6];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<List<String>> audit(WidgetTester tester, ThemeData theme) async {
    final failures = <String>[];

    for (final entry in _sizes.entries) {
      for (final scale in _scales) {
        final label = '${entry.key} @ chữ x$scale';
        final errors = <String>[];
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (d) => errors.add(d.exceptionAsString());

        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: MediaQuery(
                data: MediaQueryData(
                  size: entry.value,
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: SizedBox(
                      width: entry.value.width,
                      child: Builder(
                        builder: (ctx) => StatGrid(stats: _statsOf(ctx)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
        } finally {
          FlutterError.onError = originalOnError;
        }

        for (final e in errors.where((m) => m.contains('overflowed'))) {
          final m = RegExp(
            r'overflowed by ([\d.]+) pixels on the (\w+)',
          ).firstMatch(e);
          failures.add(
            '$label: TRÀN ${m?.group(1) ?? '?'}px chiều ${m?.group(2) ?? '?'}',
          );
        }
      }
    }
    return failures;
  }

  group('StatGrid', () {
    for (final (name, theme) in <(String, ThemeData)>[
      ('sáng', AppTheme.lightTheme),
      ('tối', AppTheme.darkTheme),
    ]) {
      testWidgets('không tràn ở chế độ $name', (tester) async {
        final failures = await audit(tester, theme);
        expect(failures, isEmpty, reason: failures.join('\n'));
      });
    }
  });
}

/// Danh sách số liệu với nhãn DÀI NHẤT mà API có thể trả về.
List<StatItem> _statsOf(BuildContext context) {
  final c = AppColors.of(context);
  return [
    StatItem(
      title: 'Tổng số khoá học đã xuất bản',
      value: '12345',
      icon: Icons.school,
      color: c.info,
    ),
    StatItem(
      title: 'Tổng người dùng đang hoạt động',
      value: '999999',
      icon: Icons.people,
      color: c.success,
    ),
    StatItem(
      title: 'Số bài kiểm tra',
      value: '12',
      icon: Icons.quiz,
      color: c.warning,
    ),
    StatItem(
      title: 'Lượt đánh giá trung bình',
      value: '4.5',
      icon: Icons.star_rate,
      color: c.error,
    ),
  ];
}
