import 'package:flutter/material.dart';

class AppTheme {
  /// Theme cho Light Mode
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF335ef7),
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  );

  /// Theme cho Dark Mode
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.green,
    scaffoldBackgroundColor: const Color(0xFF18191f),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF335ef7),
        foregroundColor: Colors.white,
      ),
    ),

    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  );
}
