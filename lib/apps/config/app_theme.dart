import 'package:flutter/material.dart';

class AppTheme {
  // Màu sắc chủ đạo
  static const Color primary = Color(0xFF2563EB); // Xanh dương tươi
  static const Color secondary = Color(0xFF10B981); // Xanh lá nhạt
  static const Color accent = Color(0xFFFF9800); // Cam nổi bật
  static const Color success = Color(0xFF22C55E); // Xanh lá
  static const Color error = Color(0xFFEF4444); // Đỏ tươi

  // Light
  static const Color backgroundLight = Color(0xFFF8FAFC); // Nền tổng thể
  static const Color surfaceLight = Color(
    0xFFFFFFFF,
  ); // Card, input, bottom bar
  static const Color textPrimaryLight = Color(0xFF1E293B); // Đen đậm
  static const Color textSecondaryLight = Color(0xFF64748B); // Xám nhạt

  // Dark
  static const Color backgroundDark = Color(0xFF181A20);
  static const Color surfaceDark = Color(0xFF1f222a);

  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Trắng nhạt
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Xám nhạt

  /// Theme cho Light Mode
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surfaceLight,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryLight,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryLight),
      titleTextStyle: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primary,
      unselectedItemColor: textSecondaryLight,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: accent, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textSecondaryLight),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimaryLight, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondaryLight, fontSize: 14),
    ),
    iconTheme: const IconThemeData(color: textPrimaryLight),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
      space: 1,
    ),
  );

  /// Theme cho Dark Mode
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surfaceDark,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimaryDark,
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimaryDark),
      titleTextStyle: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundDark,

      selectedItemColor: primary,
      unselectedItemColor: textSecondaryDark,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accent,
        side: const BorderSide(color: accent, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondary,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textSecondaryDark),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimaryDark, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondaryDark, fontSize: 14),
    ),
    iconTheme: const IconThemeData(color: textPrimaryDark),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
      space: 1,
    ),
  );
}
