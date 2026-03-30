import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_scaffold.dart';

class BuilderSignupFormExample extends StatelessWidget {
  const BuilderSignupFormExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      notifier: notifier,
      title: 'BfFormBuilder',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _LocCallout(),
            const SizedBox(height: 24),
            BfFormBuilder(
              fields: {
                'name': BfFieldConfig<String>.text(
                  label: 'Full Name',
                  hint: 'John Doe',
                  prefixIcon: Icons.person_outlined,
                  validators: [Bf.required(message: 'Name is required')],
                ),
                'email': BfFieldConfig<String>.email(
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  validators: [Bf.required(), Bf.email()],
                ),
                'password': BfFieldConfig<String>.password(
                  label: 'Password',
                  hint: 'At least 8 characters',
                  prefixIcon: Icons.lock_outlined,
                  validators: [Bf.required(), Bf.minLength(8)],
                ),
                'confirmPassword': BfFieldConfig<String>.password(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  prefixIcon: Icons.lock_outlined,
                  validators: [
                    Bf.required(),
                    Bf.matchFields<String>(
                      'password',
                      message: 'Passwords do not match',
                    ),
                  ],
                ),
                'terms': BfFieldConfig<bool>.checkbox(
                  initialValue: false,
                  label: 'I agree to the Terms and Conditions',
                  validators: [
                    Bf.equals<bool>(true, message: 'You must accept the terms'),
                  ],
                ),
              },
              onSubmit: (values) async {
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created!')),
                  );
                }
              },
              builder: (form) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  form.text('name'),
                  const SizedBox(height: 16),
                  form.email('email'),
                  const SizedBox(height: 16),
                  form.password('password'),
                  const SizedBox(height: 16),
                  form.password('confirmPassword'),
                  const SizedBox(height: 8),
                  form.checkbox('terms'),
                  const SizedBox(height: 24),
                  form.submitButton('Create Account'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocCallout extends StatelessWidget {
  const _LocCallout();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: const Border(
          left: BorderSide(color: Color(0xFFFF6B00), width: 3),
        ),
        color: cs.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '// dx note',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 10,
              color: Color(0xFFFF6B00),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This form is ~50 lines.',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'The equivalent StatefulWidget version (signup_form.dart) requires '
            '~150 lines — manual controllers, initState, dispose, and wiring. '
            'BfFormBuilder eliminates all of it.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
