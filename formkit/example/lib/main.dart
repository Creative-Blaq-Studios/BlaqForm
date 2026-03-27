import 'package:flutter/material.dart';
import 'package:formkit/formkit.dart';

import 'examples/builder_signup_form.dart';
import 'examples/checkout_form.dart';
import 'examples/signup_form.dart';
import 'examples/wizard_onboarding.dart';

void main() {
  // Enable FormKit logging so you can see lifecycle events in the console.
  FkLogger.instance
    ..level = FkLogLevel.debug
    ..useColors = true;

  runApp(const FormKitExampleApp());
}

/// Root widget for the FormKit example application.
///
/// Provides a Material 3 theme and a home screen that navigates to individual
/// form examples.
class FormKitExampleApp extends StatelessWidget {
  const FormKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormKit Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ExampleListScreen(),
    );
  }
}

/// Home screen that lists the available form examples.
class ExampleListScreen extends StatelessWidget {
  const ExampleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FormKit Examples'),
        backgroundColor: colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Signup form example card --
          _ExampleCard(
            icon: Icons.person_add_outlined,
            title: 'Signup Form',
            description:
                'Demonstrates text fields, email/password validation, '
                'cross-field matching, checkbox agreement, and submit.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupFormExample()),
            ),
          ),
          const SizedBox(height: 12),

          // -- Checkout form example card --
          _ExampleCard(
            icon: Icons.shopping_cart_outlined,
            title: 'Checkout Form',
            description:
                'Demonstrates form sections, side-by-side rows, dropdown, '
                'date picker, credit card validation, and layout widgets.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutFormExample()),
            ),
          ),
          const SizedBox(height: 12),

          // -- Builder signup form example card --
          _ExampleCard(
            icon: Icons.bolt_outlined,
            title: 'Signup (FkFormBuilder)',
            description:
                'The same signup form rewritten with FkFormBuilder — zero '
                'StatefulWidget, zero dispose, ~50 lines of declarative config.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BuilderSignupFormExample()),
            ),
          ),
          const SizedBox(height: 12),

          // -- Wizard onboarding example card --
          _ExampleCard(
            icon: Icons.linear_scale_outlined,
            title: 'Onboarding (FkWizard)',
            description:
                'A three-step onboarding wizard with per-step validation, '
                'progress indicator, and a review/confirm screen.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const WizardOnboardingExample()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable card that describes a form example.
class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
