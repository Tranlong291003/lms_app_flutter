import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(themeMode: ThemeMode.light)) {
    on<ThemeStarted>(_onThemeStarted);
    on<ThemeToggled>(_onThemeToggled);
  }

  // Khai báo key SharedPreferences
  static const String _themeKey = 'theme_mode';

  // Khi app khởi động (ThemeStarted), đọc chế độ theme đã lưu
  Future<void> _onThemeStarted(
    ThemeStarted event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeKey) ?? 'light';

    switch (modeString) {
      case 'dark':
        emit(const ThemeState(themeMode: ThemeMode.dark));
        break;
      case 'system':
        emit(const ThemeState(themeMode: ThemeMode.system));
        break;
      case 'light':
      default:
        emit(const ThemeState(themeMode: ThemeMode.light));
        break;
    }
  }

  // Khi người dùng nhấn nút chuyển theme (ThemeToggled), đảo light <-> dark và lưu
  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    final currentMode = state.themeMode;
    late ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.light;
    }

    // Lưu vào SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final newModeStr = (newMode == ThemeMode.dark) ? 'dark' : 'light';
    await prefs.setString(_themeKey, newModeStr);

    // Phát ra state mới
    emit(ThemeState(themeMode: newMode));
  }
}
