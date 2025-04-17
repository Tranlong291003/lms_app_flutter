import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeStarted extends ThemeEvent {
  @override
  List<Object> get props => [];
}

class ThemeToggled extends ThemeEvent {
  @override
  List<Object> get props => [];
}
