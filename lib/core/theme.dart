import 'package:flutter/material.dart';

class CashWiseTheme {
  static const Color primary = Color(0xFF0F766E);
  static const Color accent = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
  );
}
