import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

/// A complete signup form demonstrating core BlaqForm features:
///
/// - [BfForm] with [BfFormController] for form-level state management
/// - [BfTextField] for name, email, and password inputs
/// - [BfTextField.email] convenience constructor
/// - [BfTextField.password] convenience constructor with obscured text
/// - Cross-field validation with [Bf.matchFields] (confirm password)
/// - [BfCheckboxField] for terms agreement
/// - [BfSubmitButton] with automatic loading/disabled state
/// - Validators: [Bf.required], [Bf.email], [Bf.minLength], [Bf.matchFields]
class SignupFormExample extends StatefulWidget {
  const SignupFormExample({super.key});

  @override
  State<SignupFormExample> createState() => _SignupFormExampleState();
}

class _SignupFormExampleState extends State<SignupFormExample> {
  // -- Form controller aggregates all field controllers --
  late final BfFormController _formController;

  // -- Individual field controllers with their validators --
  late final BfFieldController<String> _nameController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _passwordController;
  late final BfFieldController<String> _confirmPasswordController;
  late final BfFieldController<bool> _termsController;

  @override
  void initState() {
    super.initState();

    _formController = BfFormController();

    // Name: simply required
    _nameController = BfFieldController<String>(
      validators: [Bf.required(message: 'Please enter your name')],
    );

    // Email: required + valid email format
    _emailController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'Email is required'),
        Bf.email(),
      ],
    );

    // Password: required + minimum 8 characters
    _passwordController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'Password is required'),
        Bf.minLength(8),
      ],
    );

    // Confirm password: required + must match the 'password' field.
    // Bf.matchFields reads the sibling field value via BfValidationContext,
    // which BfFormController provides automatically during submit().
    _confirmPasswordController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'Please confirm your password'),
        Bf.matchFields<String>('password', message: 'Passwords do not match'),
      ],
    );

    // Terms checkbox: must be exactly true to proceed.
    // Using Bf.equals(true) ensures the box is checked.
    _termsController = BfFieldController<bool>(
      initialValue: false,
      validators: [
        Bf.equals<bool>(true, message: 'You must accept the terms'),
      ],
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Form'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: BfForm(
          controller: _formController,
          autovalidateMode: BfAutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -- Full name --
              BfTextField(
                name: 'name',
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'John Doe',
                prefixIcon: const Icon(Icons.person_outlined),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // -- Email (uses .email() convenience constructor) --
              BfTextField.email(
                name: 'email',
                controller: _emailController,
                labelText: 'Email',
                hintText: 'you@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: 16),

              // -- Password (uses .password() convenience constructor) --
              BfTextField.password(
                name: 'password',
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'At least 8 characters',
                prefixIcon: const Icon(Icons.lock_outlined),
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 16),

              // -- Confirm password (cross-field validation) --
              BfTextField.password(
                name: 'confirmPassword',
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),

              // -- Terms & conditions checkbox --
              BfCheckboxField(
                name: 'terms',
                controller: _termsController,
                label: const Text('I agree to the Terms and Conditions'),
              ),
              const SizedBox(height: 24),

              // -- Submit button --
              // BfSubmitButton auto-disables when the form is invalid or
              // submitting, and shows a loading indicator during submission.
              BfSubmitButton(
                label: 'Create Account',
                disableWhenInvalid: false,
                onSubmit: (controller) async {
                  final success = await controller.submit((values) async {
                    // Simulate a network call
                    await Future.delayed(const Duration(seconds: 2));
                    debugPrint('Signup values: $values');
                  });

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account created successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
