// test/design_consistency_test.dart
//
// Test hồi quy cho các lỗi UI/UX đã sửa. Mỗi test ở đây tương ứng với một lỗi
// CỤ THỂ đã gặp trong thực tế, không phải kiểm tra chung chung — để nếu ai đó
// vô tình làm hỏng lại thì test đổ ngay.
//
// Chạy: flutter test test/design_consistency_test.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms/apps/config/app_dimens.dart';
import 'package:lms/apps/config/app_theme.dart';
import 'package:lms/apps/utils/status_chip.dart';

/// Tính tỉ lệ tương phản theo công thức WCAG 2.x.
double _contrast(Color a, Color b) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  final la = 0.2126 * channel(a.r) +
      0.7152 * channel(a.g) +
      0.0722 * channel(a.b);
  final lb = 0.2126 * channel(b.r) +
      0.7152 * channel(b.g) +
      0.0722 * channel(b.b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('Theme — tương phản màu', () {
    /// Ngưỡng WCAG AA cho chữ thường.
    const aa = 4.5;

    test('Chữ trên nền trong light mode đủ tương phản', () {
      final scheme = AppTheme.lightTheme.colorScheme;
      final pairs = <String, (Color, Color)>{
        'onSurface/surface': (scheme.onSurface, scheme.surface),
        'onSurfaceVariant/surface': (
          scheme.onSurfaceVariant,
          scheme.surface,
        ),
        'onPrimary/primary': (scheme.onPrimary, scheme.primary),
        'onSecondaryContainer/secondaryContainer': (
          scheme.onSecondaryContainer,
          scheme.secondaryContainer,
        ),
        'onPrimaryContainer/primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        'onErrorContainer/errorContainer': (
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
        'onTertiaryContainer/tertiaryContainer': (
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer,
        ),
      };
      for (final entry in pairs.entries) {
        final ratio = _contrast(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(aa),
          reason:
              '${entry.key} chỉ đạt ${ratio.toStringAsFixed(2)}:1 '
              '(cần >= $aa:1)',
        );
      }
    });

    test('Chữ trên nền trong dark mode đủ tương phản', () {
      final scheme = AppTheme.darkTheme.colorScheme;
      final pairs = <String, (Color, Color)>{
        'onSurface/surface': (scheme.onSurface, scheme.surface),
        'onSurfaceVariant/surface': (
          scheme.onSurfaceVariant,
          scheme.surface,
        ),
        'onPrimary/primary': (scheme.onPrimary, scheme.primary),
        'onError/error': (scheme.onError, scheme.error),
        'onSecondaryContainer/secondaryContainer': (
          scheme.onSecondaryContainer,
          scheme.secondaryContainer,
        ),
        'onPrimaryContainer/primaryContainer': (
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        'onErrorContainer/errorContainer': (
          scheme.onErrorContainer,
          scheme.errorContainer,
        ),
        'onTertiaryContainer/tertiaryContainer': (
          scheme.onTertiaryContainer,
          scheme.tertiaryContainer,
        ),
      };
      for (final entry in pairs.entries) {
        final ratio = _contrast(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(aa),
          reason:
              '${entry.key} chỉ đạt ${ratio.toStringAsFixed(2)}:1 '
              '(cần >= $aa:1)',
        );
      }
    });

    test('Nền snackbar với chữ trắng đủ tương phản', () {
      final fills = <String, Color>{
        'successFill': AppPalette.successFill,
        'warningFill': AppPalette.warningFill,
        'errorFill': AppPalette.errorFill,
        'infoFill': AppPalette.infoFill,
      };
      for (final entry in fills.entries) {
        final ratio = _contrast(Colors.white, entry.value);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              '${entry.key} với chữ trắng chỉ đạt '
              '${ratio.toStringAsFixed(2)}:1',
        );
      }
    });
  });

  group('Theme — vai trò màu không rơi về mặc định của Material', () {
    test('primaryContainer/tertiary không phải màu tím mặc định', () {
      // `ColorScheme.light()` mặc định cho `primaryContainer` = 0xFFEADDFF
      // (tím) và `tertiary` = 0xFF7D5260 (tím-hồng). Trước đây theme không
      // khai báo hai vai trò này nên app hiển thị chip tím giữa tông xanh.
      const materialDefaultPrimaryContainer = Color(0xFFEADDFF);
      const materialDefaultTertiary = Color(0xFF7D5260);

      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        expect(
          theme.colorScheme.primaryContainer,
          isNot(materialDefaultPrimaryContainer),
          reason: 'primaryContainer đang rơi về mặc định của Material',
        );
        expect(
          theme.colorScheme.tertiary,
          isNot(materialDefaultTertiary),
          reason: 'tertiary đang rơi về mặc định của Material',
        );
      }
    });

    test('Mọi thành phần theme bắt buộc đã được khai báo', () {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        expect(theme.cardTheme.shape, isNotNull);
        expect(theme.dialogTheme.shape, isNotNull);
        expect(theme.inputDecorationTheme.border, isNotNull);
        expect(theme.elevatedButtonTheme.style, isNotNull);
        expect(theme.outlinedButtonTheme.style, isNotNull);
        expect(theme.textButtonTheme.style, isNotNull);
        expect(theme.tabBarTheme.labelColor, isNotNull);
        expect(theme.chipTheme.shape, isNotNull);
        expect(theme.popupMenuTheme.shape, isNotNull);
        expect(theme.progressIndicatorTheme.color, isNotNull);
      }
    });

    test('Nút viền dùng màu nhấn của app, không phải màu cam cũ', () {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        final style = theme.outlinedButtonTheme.style!;
        final fg = style.foregroundColor?.resolve({});
        expect(
          fg,
          theme.colorScheme.primary,
          reason: 'Nút viền phải dùng primary',
        );
      }
    });
  });

  group('AppRadius / AppSpacing', () {
    test('Bán kính có thứ tự tăng dần', () {
      expect(AppRadius.sm, lessThan(AppRadius.md));
      expect(AppRadius.md, lessThan(AppRadius.lg));
      expect(AppRadius.lg, lessThan(AppRadius.xl));
      expect(AppRadius.xl, lessThan(AppRadius.xxl));
      expect(AppRadius.xxl, lessThan(AppRadius.pill));
    });

    test('Khoảng cách là bội của 4', () {
      for (final v in [
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ]) {
        expect(v % 4, 0, reason: '$v không phải bội của 4');
      }
    });
  });

  group('StatusChip', () {
    test('Suy ra sắc thái đúng cho cả nhãn tiếng Anh lẫn tiếng Việt', () {
      expect(StatusChip.toneFor('approved'), StatusTone.success);
      expect(StatusChip.toneFor('Đã duyệt'), StatusTone.success);
      expect(StatusChip.toneFor('pending'), StatusTone.warning);
      expect(StatusChip.toneFor('Chờ duyệt'), StatusTone.warning);
      expect(StatusChip.toneFor('rejected'), StatusTone.error);
      expect(StatusChip.toneFor('Từ chối'), StatusTone.error);
      expect(StatusChip.toneFor(''), StatusTone.neutral);
      expect(StatusChip.toneFor(null), StatusTone.neutral);
    });

    testWidgets('Nhãn trạng thái luôn có chữ, không chỉ dựa vào màu', (
      tester,
    ) async {
      // Người khó phân biệt màu vẫn phải đọc được trạng thái.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Center(
              child: StatusChip(label: 'Đang hoạt động'),
            ),
          ),
        ),
      );
      expect(find.text('Đang hoạt động'), findsOneWidget);
    });

    testWidgets('StatusChip hiển thị được ở cả hai chế độ', (tester) async {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: const Scaffold(
              body: Center(child: StatusChip(label: 'Thử')),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AppColors — màu ngữ nghĩa đổi theo chế độ', () {
    testWidgets('Chữ màu trạng thái đủ tương phản trên nền ở CẢ HAI chế độ', (
      tester,
    ) async {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        late AppColors colors;
        late Color surface;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                colors = AppColors.of(context);
                surface = Theme.of(context).colorScheme.surface;
                return const SizedBox();
              },
            ),
          ),
        );

        for (final entry in <String, Color>{
          'success': colors.success,
          'warning': colors.warning,
          'error': colors.error,
          'info': colors.info,
        }.entries) {
          final ratio = _contrast(entry.value, surface);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                '${theme.brightness.name}: AppColors.${entry.key} trên nền '
                'chỉ đạt ${ratio.toStringAsFixed(2)}:1 — màu ngữ nghĩa phải tự '
                'đổi theo chế độ sáng/tối',
          );
        }
      }
    });
  });
}
