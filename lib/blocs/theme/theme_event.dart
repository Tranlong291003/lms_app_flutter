import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// Event bắn khi app khởi động, để load theme từ SharedPreferences
class ThemeStarted extends ThemeEvent {}

/// Event bắn khi người dùng nhấn nút chuyển theme
class ThemeToggled extends ThemeEvent {}
