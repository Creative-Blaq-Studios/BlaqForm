import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'theme_toggle_button.dart';

/// Shared scaffold used by every example screen.
///
/// Shows [ThemeToggleButton] in the AppBar and paints a subtle grid
/// overlay on the scaffold background when in Dev theme.
class BrandScaffold extends StatelessWidget {
  const BrandScaffold({
    required this.notifier,
    required this.title,
    required this.body,
    this.actions = const [],
    super.key,
  });

  final AppThemeNotifier notifier;
  final String title;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BfAppTheme>(
      valueListenable: notifier,
      builder: (context, theme, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              ...actions,
              ThemeToggleButton(notifier: notifier),
              const SizedBox(width: 4),
            ],
          ),
          body: theme == BfAppTheme.dev ? _GridBackground(child: body) : body,
        );
      },
    );
  }
}

class _GridBackground extends StatelessWidget {
  const _GridBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter(), child: child);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x07FFFFFF)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
