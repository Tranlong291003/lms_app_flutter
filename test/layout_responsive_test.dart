// test/layout_responsive_test.dart
//
// Kiểm tra bố cục trên NHIỀU kích thước màn hình.
//
// `screen_smoke_test.dart` dựng màn hình ở một kích thước mặc định (800x600)
// nên không phát hiện được lỗi "chỉ xảy ra trên máy nhỏ" — đúng loại lỗi đang
// gặp: thẻ khoá học bị tràn, chip danh mục bị cắt, tiêu đề dài tràn ngang.
//
// Test này dựng cùng một widget ở các kích thước đại diện cho máy thật
// (màn hình nhỏ, phổ thông, tablet) và ở chế độ chữ lớn, rồi xác nhận KHÔNG có
// lỗi tràn (`RenderFlex overflowed`) nào được ghi nhận.
//
// Chạy: flutter test test/layout_responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/empty_state_widget.dart';
import 'package:lms/apps/utils/listCourses_widget.dart';
import 'package:lms/models/courses/courses_model.dart';

/// Các kích thước màn hình đại diện (theo đơn vị logic).
const _sizes = <String, Size>{
  'iPhone SE (nhỏ)': Size(320, 568),
  'iPhone 13 mini': Size(375, 812),
  'iPhone 16 Pro': Size(402, 874),
  'iPad (tablet)': Size(820, 1180),
};

/// Tiêu đề rất dài, không có khoảng trắng dài — trường hợp khó nhất cho xuống dòng.
const _longTitle =
    'ReactJS + Next.js toàn tập từ cơ bản đến nâng cao cùng dự án thực tế';

Course _course({required String title, int price = 1299000, int discount = 0}) {
  return Course(
    courseId: 1,
    title: title,
    description: 'Mô tả khoá học',
    instructorUid: 'u_1',
    categoryId: 1,
    price: price,
    level: 'intermediate',
    discountPrice: discount,
    thumbnailUrl: null,
    status: 'approved',
    updatedAt: DateTime(2026, 1, 1),
    instructorName: 'Trần Thị Hồng Nhung',
    categoryName: 'Lập trình Web',
    rating: 4.3,
    enrollCount: 12345,
    lessonCount: 40,
    totalDuration: '12 giờ',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Dựng [child] ở mọi kích thước và chế độ chữ, trả về danh sách lỗi tràn.
  ///
  /// Lỗi tràn được báo qua `FlutterError.onError` trong lúc layout — KHÔNG đi
  /// qua `tester.takeException()`. Nếu chỉ dựa vào `takeException` thì test
  /// báo "passed" trong khi vẫn có dải vàng đen tràn (đã kiểm chứng: test cũ
  /// bỏ sót lỗi tràn 131px). Vì vậy phải tự bắt qua `FlutterError.onError`.
  Future<List<String>> overflowAt(WidgetTester tester, Widget child) async {
    final failures = <String>[];
    final originalOnError = FlutterError.onError;

    for (final entry in _sizes.entries) {
      for (final scale in <double>[1.0, 1.3]) {
        final label = '${entry.key} @ chữ x$scale';
        final errors = <String>[];

        FlutterError.onError = (details) {
          // Gồm cả `context` (chuỗi widget gây lỗi) — chính là phần "creator:"
          // hiển thị trên console.
          final buf = StringBuffer(details.exceptionAsString());
          final ctx = details.context;
          if (ctx != null) buf.write('\n  $ctx');
          errors.add(buf.toString());
        };

        try {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                size: entry.value,
                textScaler: TextScaler.linear(scale),
              ),
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: Scaffold(
                  body: SizedBox(
                    width: entry.value.width,
                    height: entry.value.height,
                    child: SingleChildScrollView(child: child),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
        } finally {
          FlutterError.onError = originalOnError;
        }

        final overflow = errors.where((m) => m.contains('overflowed'));
        if (overflow.isNotEmpty) {
          final first = overflow.first;
          final m = RegExp(
            r'overflowed by ([\d.]+) pixels on the (\w+)',
          ).firstMatch(first);
          failures.add(
            '$label: tràn ${m?.group(1) ?? '?'}px chiều ${m?.group(2) ?? '?'}',
          );
        }
      }
    }

    return failures;
  }

  testWidgets('Thẻ khoá học không tràn ở mọi kích thước màn hình', (
    tester,
  ) async {
    final failures = await overflowAt(
      tester,
      ListCoursesWidget(
        courses: [_course(title: _longTitle)],
        userUid: '',
      ),
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('Thẻ khoá học có giá giảm không tràn', (tester) async {
    final failures = await overflowAt(
      tester,
      ListCoursesWidget(
        courses: [_course(title: _longTitle, discount: 499000)],
        userUid: '',
      ),
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('Trạng thái rỗng không tràn ở mọi kích thước', (tester) async {
    final failures = await overflowAt(
      tester,
      const EmptyStateWidget(
        icon: Icons.menu_book_outlined,
        title: 'Chưa có khoá học nào',
        message: 'Các khoá học mới sẽ xuất hiện ở đây.',
        actionLabel: 'Thử lại',
        onAction: _noop,
      ),
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('Danh sách nhiều khoá học không tràn', (tester) async {
    final failures = await overflowAt(
      tester,
      ListCoursesWidget(
        courses: [
          _course(title: _longTitle),
          _course(title: 'HTML CSS từ Zero đến Hero', discount: 499000),
          _course(title: 'A' * 200),
        ],
        userUid: '',
      ),
    );
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}

void _noop() {}
