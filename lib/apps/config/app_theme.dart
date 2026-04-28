import 'package:flutter/material.dart';

class AppTheme {
  // Brand palette
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFFF97316);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  // Light
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEFF3FF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF172033);
  static const Color surfaceVariantDark = Color(0xFF23304A);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  static const Color _outlineLight = Color(0xFFD8E0F0);
  static const Color _outlineDark = Color(0xFF334155);

  /// Theme cho Light Mode
  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: surfaceLight,
      surfaceContainerHighest: surfaceVariantLight,
      outline: _outlineLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      onError: Colors.white,
    ),
  );

  /// Theme cho Dark Mode
  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: surfaceDark,
      surfaceContainerHighest: surfaceVariantDark,
      outline: _outlineDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      onError: Colors.black,
    ),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? backgroundDark : backgroundLight;
    final textPrimary = isDark ? textPrimaryDark : textPrimaryLight;
    final textSecondary = isDark ? textSecondaryDark : textSecondaryLight;

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.12,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.18,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.45),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14, height: 1.4),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Roboto',
      textTheme: textTheme,
      iconTheme: IconThemeData(color: textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 8,
        shadowColor: primary.withOpacity(isDark ? 0 : 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline, width: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(isDark ? 0.7 : 0.55),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.error, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: TextStyle(color: textSecondary),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primary,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        labelStyle: textTheme.labelMedium?.copyWith(color: textSecondary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(isDark ? 0.22 : 0.12),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? colorScheme.primary : textSecondary,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : textSecondary,
            size: selected ? 25 : 23,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? surfaceVariantDark : textPrimaryLight,
        contentTextStyle: TextStyle(
          color: isDark ? textPrimaryDark : Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
