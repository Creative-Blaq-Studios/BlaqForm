import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// AppBar action that toggles between Dev and Studio themes.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BfAppTheme>(
      valueListenable: notifier,
      builder: (context, theme, _) {
        return IconButton(
          tooltip: theme == BfAppTheme.dev
              ? 'Switch to Studio theme'
              : 'Switch to Dev theme',
          icon: Icon(
            theme == BfAppTheme.dev
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: notifier.toggle,
        );
      },
    );
  }
}
