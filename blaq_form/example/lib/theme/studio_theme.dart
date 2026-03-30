import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

abstract final class StudioTheme {
  static const _accent = Color(0xFFE06000);
  static const _bg = Color(0xFFFFFFFF);
  static const _surface = Color(0xFFFAFAFA);
  static const _border = Color(0xFFEBEBEB);
  static const _textPrimary = Color(0xFF1A1A1A);
  static const _textMuted = Color(0xFF888888);
  static const _error = Color(0xFFDC2626);

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: _bg,
    colorScheme: ColorScheme.light(
      primary: _accent,
      onPrimary: Colors.white,
      secondary: _accent,
      onSecondary: Colors.white,
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
        fontWeight: FontWeight.w800,
        fontSize: 16,
        letterSpacing: -0.01,
        color: _textPrimary,
      ),
      iconTheme: IconThemeData(color: _textPrimary),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: _bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _border),
      ),
    ),
    dividerTheme: const DividerThemeData(color: _border, space: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: _error, width: 1.5),
      ),
      labelStyle: const TextStyle(color: _textMuted, fontSize: 13),
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
      errorStyle: TextStyle(color: _error, fontSize: 11),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: [bfTheme],
  );

  static BfFormTheme get bfTheme => BfFormTheme(
    fieldBorderRadius: BorderRadius.circular(8),
    fieldSpacing: 16.0,
    sectionSpacing: 28.0,
    errorDisplay: BfErrorDisplay.inline,
    errorStyle: const TextStyle(color: _error, fontSize: 11),
    labelStyle: const TextStyle(color: _textMuted, fontSize: 12),
    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
  );
}
