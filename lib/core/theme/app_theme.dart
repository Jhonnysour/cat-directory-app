import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _terracotta = Color(0xFF9A4F2C);
  static const _fontFamily = 'NunitoSans';

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _terracotta,
      brightness: brightness,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFFFF8F4)
          : colorScheme.surface,
      fontFamily: _fontFamily,
      useMaterial3: true,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
