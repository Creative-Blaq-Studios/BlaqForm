import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import 'theme/app_theme.dart';
import 'widgets/theme_toggle_button.dart';
import 'examples/signup_form.dart';
import 'examples/checkout_form.dart';
import 'examples/builder_signup_form.dart';
import 'examples/wizard_onboarding.dart';
import 'examples/kitchen_sink.dart';
import 'examples/theme_showcase.dart';

void main() {
  BfLogger.instance
    ..level = BfLogLevel.debug
    ..useColors = true;

  runApp(BlaqFormExampleApp());
}

class BlaqFormExampleApp extends StatelessWidget {
  BlaqFormExampleApp({super.key});

  final _themeNotifier = AppThemeNotifier();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BfAppTheme>(
      valueListenable: _themeNotifier,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'BlaqForm',
          debugShowCheckedModeBanner: false,
          theme: _themeNotifier.themeData,
          home: HomeScreen(notifier: _themeNotifier),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  static const _examples = [
    _ExampleMeta(
      tag: '01',
      title: 'Signup Form',
      description: 'BfFieldStatus · BfFormProgress · BfDirtyGuard',
      icon: Icons.person_add_outlined,
    ),
    _ExampleMeta(
      tag: '02',
      title: 'Checkout',
      description: 'BfFormSection · BfFormRow · BfDropdownField · BfDateField',
      icon: Icons.shopping_bag_outlined,
    ),
    _ExampleMeta(
      tag: '03',
      title: 'BfFormBuilder',
      description: 'Zero controllers · declarative config · ~50 lines',
      icon: Icons.bolt_outlined,
    ),
    _ExampleMeta(
      tag: '04',
      title: 'BfWizard',
      description: 'Multi-step · per-step validation · progress indicator',
      icon: Icons.linear_scale_outlined,
    ),
    _ExampleMeta(
      tag: '05',
      title: 'Kitchen Sink',
      description: 'Every field type in one scrollable form',
      icon: Icons.widgets_outlined,
    ),
    _ExampleMeta(
      tag: '06',
      title: 'Theme Showcase',
      description: 'Dev ↔ Studio side-by-side on the same form',
      icon: Icons.palette_outlined,
    ),
  ];

  void _navigate(BuildContext context, int index) {
    final destinations = [
      SignupFormExample(notifier: notifier),
      CheckoutFormExample(notifier: notifier),
      BuilderSignupFormExample(notifier: notifier),
      WizardOnboardingExample(notifier: notifier),
      KitchenSinkExample(notifier: notifier),
      ThemeShowcaseExample(notifier: notifier),
    ];
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinations[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDev = notifier.isDev;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BLAQFORM',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.12,
            color: cs.onSurface,
          ),
        ),
        actions: [
          ThemeToggleButton(notifier: notifier),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomPaint(
        painter: isDev ? _GridPainter(color: const Color(0x07FFFFFF)) : null,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _HomeHeader(isDev: isDev),
            const SizedBox(height: 32),
            ...List.generate(
              _examples.length,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: isDev ? 2 : 8),
                child: _ExampleTile(
                  meta: _examples[i],
                  isDev: isDev,
                  onTap: () => _navigate(context, i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.isDev});

  final bool isDev;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '// examples',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 11,
            letterSpacing: 0.2,
            color: Color(0xFFFF6B00),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Composable\nFlutter forms.',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 32,
            height: 1.0,
            letterSpacing: -0.03,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Prebuilt validations · adaptive fields · developer-first API.',
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.meta,
    required this.isDev,
    required this.onTap,
  });

  final _ExampleMeta meta;
  final bool isDev;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: isDev ? BorderRadius.zero : BorderRadius.circular(10),
        side: BorderSide(color: cs.outline),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0x14FF6B00),
        highlightColor: const Color(0x0AFF6B00),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Text(
                '// ${meta.tag}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: Color(0xFFFF6B00),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                meta.icon,
                size: 20,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.description,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.35),
                        letterSpacing: 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: cs.onSurface.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleMeta {
  const _ExampleMeta({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String tag;
  final String title;
  final String description;
  final IconData icon;
}
