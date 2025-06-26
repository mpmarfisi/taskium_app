import 'package:flutter/material.dart';

class AppTheme {
  final Color selectedColor;
  final bool isDarkMode;
  final double fontSize;

  AppTheme({
    this.selectedColor = const Color.fromARGB(255, 255, 0, 0),
    this.isDarkMode = false,
    this.fontSize = 16.0, // Default font size
  });

  ThemeData getTheme() {
    return ThemeData(
      colorSchemeSeed: selectedColor,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize),
        bodyMedium: TextStyle(fontSize: fontSize),
        displayLarge: TextStyle(fontSize: fontSize * 1.5, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: fontSize * 1.2, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
    );
  }

  AppTheme copyWith({
    Color? selectedColor,
    bool? isDarkMode,
    double? fontSize,
  }) {
    return AppTheme(
      selectedColor: selectedColor ?? this.selectedColor,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}