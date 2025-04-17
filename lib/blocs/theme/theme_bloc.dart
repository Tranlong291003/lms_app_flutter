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

  static const String _themeKey = 'theme_mode';

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

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    // Emit loading state
    emit(state.copyWith(isLoading: true));

    final currentMode = state.themeMode;
    late ThemeMode newMode;

    if (currentMode == ThemeMode.light) {
      newMode = ThemeMode.dark;
    } else {
      newMode = ThemeMode.light;
    }

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final newModeStr = (newMode == ThemeMode.dark) ? 'dark' : 'light';
    await prefs.setString(_themeKey, newModeStr);

    // Emit the updated theme and stop loading
    emit(state.copyWith(themeMode: newMode, isLoading: false));
  }
}
