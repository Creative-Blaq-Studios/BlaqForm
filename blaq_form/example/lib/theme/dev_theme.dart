import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

abstract final class DevTheme {
  static const _accent = Color(0xFFFF6B00);
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF0D0D0D);
  static const _border = Color(0xFF1A1A1A);
  static const _textPrimary = Color(0xFFF5F5F5);
  static const _textMuted = Color(0xFF888888);
  static const _error = Color(0xFFEF4444);

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _bg,
    colorScheme: const ColorScheme.dark(
      primary: _accent,
      onPrimary: Colors.black,
      secondary: _accent,
      onSecondary: Colors.black,
      surface: _surface,
      onSurface: _textPrimary,
      error: _error,
      outline: _border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _bg,
      foregroundColor: _textPrimary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.w900,
        fontSize: 16,
        letterSpacing: 0.04,
        color: _textPrimary,
      ),
      iconTheme: IconThemeData(color: _textPrimary),
    ),
    cardTheme: const CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: _border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: _border, space: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.08,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        side: const BorderSide(color: _accent),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF080808),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: _error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: _error, width: 1.5),
      ),
      labelStyle: TextStyle(color: _textMuted, fontSize: 13),
      hintStyle: TextStyle(color: Color(0xFF444444), fontSize: 13),
      errorStyle: TextStyle(color: _error, fontSize: 11),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: Color(0xFF1A1A1A),
      contentTextStyle: TextStyle(color: _textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: [bfTheme],
  );

  static BfFormTheme get bfTheme => const BfFormTheme(
    fieldBorderRadius: BorderRadius.zero,
    fieldSpacing: 16.0,
    sectionSpacing: 28.0,
    errorDisplay: BfErrorDisplay.inline,
    errorStyle: TextStyle(color: _error, fontSize: 11),
    labelStyle: TextStyle(color: _textMuted, fontSize: 12),
    hintStyle: TextStyle(color: Color(0xFF444444), fontSize: 13),
  );
}
