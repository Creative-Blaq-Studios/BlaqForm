import 'package:flutter/material.dart';
import 'dev_theme.dart';
import 'studio_theme.dart';

enum BfAppTheme { dev, studio }

/// Root theme notifier. Lives in main.dart, drives MaterialApp rebuild.
class AppThemeNotifier extends ValueNotifier<BfAppTheme> {
  AppThemeNotifier() : super(BfAppTheme.dev);

  void toggle() {
    value = value == BfAppTheme.dev ? BfAppTheme.studio : BfAppTheme.dev;
  }

  ThemeData get themeData =>
      value == BfAppTheme.dev ? DevTheme.themeData : StudioTheme.themeData;

  bool get isDev => value == BfAppTheme.dev;
}
