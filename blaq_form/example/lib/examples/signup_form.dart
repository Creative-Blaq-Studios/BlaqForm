import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_scaffold.dart';

class SignupFormExample extends StatefulWidget {
  const SignupFormExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  State<SignupFormExample> createState() => _SignupFormExampleState();
}

class _SignupFormExampleState extends State<SignupFormExample> {
  late final BfFormController _formController;
  late final BfFieldController<String> _nameController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _passwordController;
  late final BfFieldController<String> _confirmPasswordController;
  late final BfFieldController<bool> _termsController;

  @override
  void initState() {
    super.initState();
    _formController = BfFormController();
    _nameController = BfFieldController<String>(
      validators: [Bf.required(message: 'Name is required')],
    );
    _emailController = BfFieldController<String>(
      validators: [Bf.required(), Bf.email()],
    );
    _passwordController = BfFieldController<String>(
      validators: [Bf.required(), Bf.minLength(8)],
    );
    _confirmPasswordController = BfFieldController<String>(
      validators: [
        Bf.required(),
        Bf.matchFields<String>('password', message: 'Passwords do not match'),
      ],
    );
    _termsController = BfFieldController<bool>(
      initialValue: false,
      validators: [Bf.equals<bool>(true, message: 'You must accept the terms')],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      notifier: widget.notifier,
      title: 'Signup Form',
      body: BfDirtyGuard(
        controller: _formController,
        child: Column(
          children: [
            _ProgressHeader(controller: _formController),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: BfForm(
                  controller: _formController,
                  autovalidateMode: BfAutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FieldWithStatus(
                        field: BfTextField(
                          name: 'name',
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'John Doe',
                          prefixIcon: const Icon(Icons.person_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                        status: BfFieldStatus(controller: _nameController),
                      ),
                      const SizedBox(height: 16),
                      _FieldWithStatus(
                        field: BfTextField.email(
                          name: 'email',
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                        status: BfFieldStatus(controller: _emailController),
                      ),
                      const SizedBox(height: 16),
                      _FieldWithStatus(
                        field: BfTextField.password(
                          name: 'password',
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'At least 8 characters',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          textInputAction: TextInputAction.next,
                        ),
                        status: BfFieldStatus(controller: _passwordController),
                      ),
                      const SizedBox(height: 16),
                      _FieldWithStatus(
                        field: BfTextField.password(
                          name: 'confirmPassword',
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Re-enter password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          textInputAction: TextInputAction.done,
                        ),
                        status: BfFieldStatus(
                          controller: _confirmPasswordController,
                        ),
                      ),
                      const SizedBox(height: 12),
                      BfCheckboxField(
                        name: 'terms',
                        controller: _termsController,
                        label: const Text(
                          'I agree to the Terms and Conditions',
                        ),
                      ),
                      const SizedBox(height: 28),
                      BfSubmitButton(
                        label: 'Create Account',
                        disableWhenInvalid: false,
                        onSubmit: (controller) async {
                          final success = await controller.submit((
                            values,
                          ) async {
                            await Future.delayed(const Duration(seconds: 2));
                          });
                          if (success && mounted) {
                            _showSuccess(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _SuccessScreen(notifier: widget.notifier),
      ),
    );
  }
}

class _FieldWithStatus extends StatelessWidget {
  const _FieldWithStatus({required this.field, required this.status});

  final Widget field;
  final BfFieldStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: field),
        const SizedBox(width: 10),
        status,
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.controller});

  final BfFormController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: BfFormProgress(
        controller: controller,
        color: const Color(0xFFFF6B00),
        backgroundColor: const Color(0xFF1A1A1A),
        height: 3,
        labelBuilder: (valid, total) => '$valid / $total fields complete',
      ),
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.notifier});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BrandScaffold(
      notifier: notifier,
      title: 'Account Created',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(height: 20),
              Text(
                'You\'re in.',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: -0.02,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Account created successfully.',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Back to Examples'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
