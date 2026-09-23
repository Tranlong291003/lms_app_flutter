import 'package:flutter/material.dart';

import 'app_dimens.dart';

/// Tông màu và theme của toàn app.
///
/// ## Vì sao tách [AppPalette] khỏi [AppTheme]
///
/// Trước đây các màn hình lấy thẳng `AppTheme.error` / `AppTheme.success` để
/// tô chữ. Hai màu đó là màu *thương hiệu* (đậm, dùng cho nền nút), khi nằm
/// trên nền tối thì tương phản rất thấp: `error` đo được 3.6:1 và `success`
/// 2.1:1 — dưới ngưỡng 4.5:1 của WCAG AA cho chữ thường. Trên nền tối người
/// dùng gần như không đọc được.
///
/// [AppPalette] giữ nguyên các màu thương hiệu (không phá vỡ nhận diện), đồng
/// thời cung cấp `*OnDark` là bản sáng hơn của cùng tông dùng khi chữ nằm trên
/// nền tối — độ tương phản khi đó đạt ~8:1.
abstract final class AppPalette {
  // ── Màu thương hiệu ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB); // Xanh dương
  static const Color secondary = Color(0xFF10B981); // Xanh lá
  static const Color accent = Color(0xFFFF9800); // Cam
  static const Color success = Color(0xFF22C55E); // Xanh lá đậm
  static const Color error = Color(0xFFEF4444); // Đỏ
  static const Color warning = accent;

  // ── Bản sáng hơn, dùng cho chữ/icon trên NỀN TỐI ────────────────────────
  static const Color primaryOnDark = Color(0xFF7BA6F5);
  static const Color secondaryOnDark = Color(0xFF4ADE80);
  static const Color successOnDark = Color(0xFF56D98A);
  static const Color errorOnDark = Color(0xFFFCA5A5);
  static const Color warningOnDark = Color(0xFFFFC266);

  // ── Nền ĐẬM cho thành phần "đổ màu" (snackbar, badge) ───────────────────
  //
  // Màu thương hiệu ở trên là màu *tươi*, hợp làm điểm nhấn nhưng quá sáng để
  // làm nền có chữ trắng: đo được `success` chỉ 2.3:1 và `accent` 2.2:1 — dưới
  // xa ngưỡng 4.5:1. Các màu dưới đây là cùng tông nhưng tối hơn, cho tương
  // phản 6.5–8.3:1 với chữ trắng.
  static const Color successFill = Color(0xFF166534);
  static const Color warningFill = Color(0xFFB45309);
  static const Color errorFill = Color(0xFFB91C1C);
  static const Color infoFill = primary;

  // ── Bề mặt ──────────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Nền của khối phụ (ô nhập, chip chưa chọn) trên nền sáng.
  static const Color surfaceVariantLight = Color(0xFFE9EEF5);

  /// Viền phân cách, viền thẻ.
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color backgroundDark = Color(0xFF181A20);
  static const Color surfaceDark = Color(0xFF1F222A);
  static const Color surfaceVariantDark = Color(0xFF2A2E38);
  static const Color borderDark = Color(0xFF38404E);

  // ── Chữ ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}

class AppTheme {
  // ── Lối gọi tương thích ─────────────────────────────────────────────────
  //
  // Nhiều màn hình đang viết `AppTheme.primary`, `AppTheme.error`… Giữ lại các
  // tên này trỏ về [AppPalette] để không phải sửa hàng trăm chỗ một lượt.
  // Code mới nên dùng thẳng `Theme.of(context).colorScheme.*`.
  static const Color primary = AppPalette.primary;
  static const Color secondary = AppPalette.secondary;
  static const Color accent = AppPalette.accent;
  static const Color success = AppPalette.success;
  static const Color error = AppPalette.error;

  static const Color backgroundLight = AppPalette.backgroundLight;
  static const Color surfaceLight = AppPalette.surfaceLight;
  static const Color textPrimaryLight = AppPalette.textPrimaryLight;
  static const Color textSecondaryLight = AppPalette.textSecondaryLight;
  static const Color backgroundDark = AppPalette.backgroundDark;
  static const Color surfaceDark = AppPalette.surfaceDark;
  static const Color textPrimaryDark = AppPalette.textPrimaryDark;
  static const Color textSecondaryDark = AppPalette.textSecondaryDark;

  /// Bảng chữ đầy đủ cho cả hai chế độ.
  ///
  /// Trước đây theme chỉ khai báo 4 style (displayLarge, titleLarge, bodyLarge,
  /// bodyMedium) trong khi app dùng `titleMedium` 104 lần, `bodySmall` 42 lần…
  /// Những style thiếu sẽ rơi về mặc định của Material: cỡ chữ lệch nhau giữa
  /// các màn hình và ở dark mode chữ có thể ra màu đen trên nền tối.
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
      bodySmall: TextStyle(color: secondary, fontSize: 12),
      labelLarge: TextStyle(
        color: primary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(color: secondary, fontSize: 12),
      labelSmall: TextStyle(color: secondary, fontSize: 11),
    );
  }

  /// Bảng màu Material suy ra từ một bảng màu thương hiệu.
  ///
  /// Điểm mấu chốt: KHAI BÁO ĐẦY ĐỦ các vai trò mà app thực sự dùng
  /// (`surfaceContainerHighest`, `onSurfaceVariant`, `outlineVariant`,
  /// `primaryContainer`, `tertiary`…).
  ///
  /// Trước đây theme chỉ truyền 9 vai trò rồi để phần còn lại rơi về mặc định
  /// của `ColorScheme.light/dark`. Hệ quả là `primaryContainer` mặc định ra
  /// **tím** (0xFFEADDFF) và `tertiary` cũng ra **tím-hồng** — trong khi app
  /// dùng `primaryContainer` làm nền tag danh mục và `tertiary` làm màu tag
  /// cấp độ "Cơ bản". Kết quả: các chip tím lạc lõng giữa tông xanh của app,
  /// và ở dark mode chúng còn đổi màu khác hẳn light mode.
  static ColorScheme _buildColorScheme({
    required Brightness brightness,
    required Color surface,
    required Color surfaceVariant,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color tertiary,
    required Color onTertiary,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
    required Color shadow,
  }) {
    final isDark = brightness == Brightness.dark;

    // Các bậc "container" của Material: trên nền sáng thì càng cao càng tối,
    // trên nền tối thì ngược lại (càng cao càng sáng để nổi lên khỏi nền).
    Color tint(double t) =>
        Color.lerp(surface, onSurface, isDark ? t : t * 0.9)!;

    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: isDark
          ? const Color(0xFF3A2E1B)
          : const Color(0xFFFFE7C2),
      onTertiaryContainer: isDark
          ? const Color(0xFFFFD79A)
          : const Color(0xFF7A4A00),
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceDim: tint(0.06),
      surfaceBright: isDark ? tint(0.14) : surface,
      surfaceContainerLowest: isDark ? const Color(0xFF14161B) : Colors.white,
      surfaceContainerLow: tint(0.02),
      // `surfaceContainer` chính là "nền khối phụ" mà app dùng nhiều.
      surfaceContainer: surfaceVariant,
      surfaceContainerHigh: tint(0.06),
      surfaceContainerHighest: surfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: Colors.black,
      inverseSurface: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B),
      onInverseSurface: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F5F9),
      inversePrimary: isDark ? AppPalette.primary : const Color(0xFFA8C5F8),
      surfaceTint: primary,
    );
  }

  /// Theme cho Light Mode
  static final ThemeData lightTheme = _build(
    brightness: Brightness.light,
    colorScheme: _buildColorScheme(
      brightness: Brightness.light,
      surface: AppPalette.surfaceLight,
      surfaceVariant: AppPalette.surfaceVariantLight,
      onSurface: AppPalette.textPrimaryLight,
      onSurfaceVariant: AppPalette.textSecondaryLight,
      outline: AppPalette.borderLight,
      outlineVariant: const Color(0xFFEEF2F7),
      primary: AppPalette.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDCE7FD),
      onPrimaryContainer: const Color(0xFF153A87),
      secondary: AppPalette.secondary,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD3F5E6),
      onSecondaryContainer: const Color(0xFF065F46),
      // Cấp độ "Cơ bản" — trước đây rơi về tím mặc định của Material.
      tertiary: const Color(0xFF0284C7),
      onTertiary: Colors.white,
      error: AppPalette.error,
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF7F1D1D),
      shadow: const Color(0xFF64748B),
    ),
    background: AppPalette.backgroundLight,
    textPrimary: AppPalette.textPrimaryLight,
    textSecondary: AppPalette.textSecondaryLight,
    border: AppPalette.borderLight,
  );

  /// Theme cho Dark Mode
  static final ThemeData darkTheme = _build(
    brightness: Brightness.dark,
    colorScheme: _buildColorScheme(
      brightness: Brightness.dark,
      surface: AppPalette.surfaceDark,
      surfaceVariant: AppPalette.surfaceVariantDark,
      onSurface: AppPalette.textPrimaryDark,
      onSurfaceVariant: AppPalette.textSecondaryDark,
      outline: AppPalette.borderDark,
      outlineVariant: const Color(0xFF2F3742),
      // Dùng bản sáng hơn để chữ/icon màu primary đủ tương phản trên nền tối.
      primary: AppPalette.primaryOnDark,
      onPrimary: const Color(0xFF0B1F44),
      primaryContainer: const Color(0xFF1E3A6E),
      onPrimaryContainer: const Color(0xFFCFE0FF),
      secondary: AppPalette.secondaryOnDark,
      onSecondary: const Color(0xFF04331F),
      secondaryContainer: const Color(0xFF114A38),
      onSecondaryContainer: const Color(0xFFB8F0D8),
      tertiary: const Color(0xFF7DD3FC),
      onTertiary: const Color(0xFF053049),
      error: AppPalette.errorOnDark,
      onError: const Color(0xFF4C0519),
      errorContainer: const Color(0xFF5C1A1A),
      onErrorContainer: const Color(0xFFFECACA),
      shadow: Colors.black,
    ),
    background: AppPalette.backgroundDark,
    textPrimary: AppPalette.textPrimaryDark,
    textSecondary: AppPalette.textSecondaryDark,
    border: AppPalette.borderDark,
  );

  /// Phần dùng chung của hai theme — viết một lần để light/dark không lệch nhau.
  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color background,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;

    final base = ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      // Các nhãn/màu mặc định lấy từ colorScheme, tránh Material tự suy ra
      // màu tím mặc định ở những thành phần chưa khai báo.
      useMaterial3: true,
    );

    final textTheme = _buildTextTheme(textPrimary, textSecondary);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: textPrimary),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Mọi thẻ trong app dùng chung một dáng: nền `surface`, bo góc `lg`,
      // viền mảnh thay cho đổ bóng (đổ bóng trên nền tối gần như vô hình).
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderLg,
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderXl),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        showDragHandle: true,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          // Chiều cao tối thiểu 48px để vùng chạm đạt chuẩn Material.
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xxl,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xxl,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          // Trước đây mọi nút viền dùng màu CAM (`accent`) trong khi phần còn
          // lại của app là xanh — nhìn như hai bộ giao diện ghép lại.
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xxl,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(48, AppSizes.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),

      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.titleMedium,
        unselectedLabelStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w400,
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelLarge,
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderPill,
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimary
              : colorScheme.onSurfaceVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm / 2),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary
              : colorScheme.outline,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
        textStyle: textTheme.bodyLarge,
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: AppRadius.borderSm,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      // KHÔNG khai báo `iconButtonTheme` với `minimumSize: 48`: nút đánh dấu
      // khoá học nằm trong khung 32x32 (`listCourses_widget`) nên vùng chạm tối
      // thiểu 48px sẽ đẩy nút tràn ra ngoài khung. Những chỗ thật sự cần vùng
      // chạm lớn thì tự khai báo tại chỗ.
      splashFactory: InkSparkle.splashFactory,
    );
  }
}

/// Bốn màu ngữ nghĩa của theme hiện tại.
///
/// Đây là lớp nên dùng thay cho `Colors.green` / `AppTheme.error` khi tô chữ,
/// icon hoặc nền chip trạng thái — nó tự chọn bản đủ tương phản theo sáng/tối.
///
/// ```dart
/// final c = AppColors.of(context);
/// Icon(Icons.check_circle, color: c.success)
/// ```
class AppColors {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  /// Bản nhạt dùng làm NỀN cho chip trạng thái (chữ đậm nằm trên).
  final Color successContainer;
  final Color warningContainer;
  final Color errorContainer;
  final Color infoContainer;

  const AppColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.successContainer,
    required this.warningContainer,
    required this.errorContainer,
    required this.infoContainer,
  });

  /// Lấy bảng màu ngữ nghĩa của theme đang dùng.
  static AppColors of(BuildContext context) =>
      AppColors.from(Theme.of(context));

  factory AppColors.from(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return AppColors(
      success: isDark ? AppPalette.successOnDark : AppPalette.success,
      warning: isDark ? AppPalette.warningOnDark : AppPalette.accent,
      error: isDark ? AppPalette.errorOnDark : AppPalette.error,
      info: theme.colorScheme.primary,
      successContainer: theme.colorScheme.secondaryContainer,
      warningContainer: theme.colorScheme.tertiaryContainer,
      errorContainer: theme.colorScheme.errorContainer,
      infoContainer: theme.colorScheme.primaryContainer,
    );
  }
}
