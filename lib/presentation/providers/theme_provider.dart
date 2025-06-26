import 'dart:ui';

import 'package:taskium/core/theme/app_theme.dart';
import 'package:riverpod/riverpod.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, AppTheme>((ref) => ThemeNotifier());

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(AppTheme());

  void setDarkMode(bool isDarkMode) {
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  void setColorTheme(Color color) {
    state = state.copyWith(selectedColor: color);
  }

  void setFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
  }

  void resetTheme() {
    state = AppTheme(); // Reset to default theme
  }
}