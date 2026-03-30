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
    // Home shell is always dark — acts as neutral stage.
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text(
          'BLAQFORM',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.12,
            color: Color(0xFFF5F5F5),
          ),
        ),
        actions: [
          ThemeToggleButton(notifier: notifier),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomPaint(
        painter: _HomePainter(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            const _HomeHeader(),
            const SizedBox(height: 32),
            ...List.generate(
              _examples.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: _ExampleTile(
                  meta: _examples[i],
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

class _HomePainter extends CustomPainter {
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
  bool shouldRepaint(_HomePainter old) => false;
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
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
        const Text(
          'Composable\nFlutter forms.',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 32,
            height: 1.0,
            letterSpacing: -0.03,
            color: Color(0xFFF5F5F5),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Prebuilt validations · adaptive fields · developer-first API.',
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFFF5F5F5).withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({required this.meta, required this.onTap});

  final _ExampleMeta meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0D0D0D),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFF1A1A1A)),
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
              Icon(meta.icon, size: 20, color: const Color(0xFF555555)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.description,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10,
                        color: Color(0xFF555555),
                        letterSpacing: 0.05,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 14,
                color: Color(0xFF333333),
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
