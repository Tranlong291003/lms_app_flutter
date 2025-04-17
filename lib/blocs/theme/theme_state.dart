import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoading; // Track loading state

  const ThemeState({
    required this.themeMode,
    this.isLoading = false, // Default to not loading
  });

  ThemeState copyWith({ThemeMode? themeMode, bool? isLoading}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [themeMode, isLoading];
}
