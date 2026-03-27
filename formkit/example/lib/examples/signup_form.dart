import 'package:flutter/material.dart';
import 'package:formkit/formkit.dart';

/// A complete signup form demonstrating core FormKit features:
///
/// - [FkForm] with [FkFormController] for form-level state management
/// - [FkTextField] for name, email, and password inputs
/// - [FkTextField.email] convenience constructor
/// - [FkTextField.password] convenience constructor with obscured text
/// - Cross-field validation with [Fk.matchFields] (confirm password)
/// - [FkCheckboxField] for terms agreement
/// - [FkSubmitButton] with automatic loading/disabled state
/// - Validators: [Fk.required], [Fk.email], [Fk.minLength], [Fk.matchFields]
class SignupFormExample extends StatefulWidget {
  const SignupFormExample({super.key});

  @override
  State<SignupFormExample> createState() => _SignupFormExampleState();
}

class _SignupFormExampleState extends State<SignupFormExample> {
  // -- Form controller aggregates all field controllers --
  late final FkFormController _formController;

  // -- Individual field controllers with their validators --
  late final FkFieldController<String> _nameController;
  late final FkFieldController<String> _emailController;
  late final FkFieldController<String> _passwordController;
  late final FkFieldController<String> _confirmPasswordController;
  late final FkFieldController<bool> _termsController;

  @override
  void initState() {
    super.initState();

    _formController = FkFormController();

    // Name: simply required
    _nameController = FkFieldController<String>(
      validators: [Fk.required(message: 'Please enter your name')],
    );

    // Email: required + valid email format
    _emailController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'Email is required'),
        Fk.email(),
      ],
    );

    // Password: required + minimum 8 characters
    _passwordController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'Password is required'),
        Fk.minLength(8),
      ],
    );

    // Confirm password: required + must match the 'password' field.
    // Fk.matchFields reads the sibling field value via FkValidationContext,
    // which FkFormController provides automatically during submit().
    _confirmPasswordController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'Please confirm your password'),
        Fk.matchFields<String>('password', message: 'Passwords do not match'),
      ],
    );

    // Terms checkbox: must be exactly true to proceed.
    // Using Fk.equals(true) ensures the box is checked.
    _termsController = FkFieldController<bool>(
      initialValue: false,
      validators: [
        Fk.equals<bool>(true, message: 'You must accept the terms'),
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
        child: FkForm(
          controller: _formController,
          autovalidateMode: FkAutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // -- Full name --
              FkTextField(
                name: 'name',
                controller: _nameController,
                labelText: 'Full Name',
                hintText: 'John Doe',
                prefixIcon: const Icon(Icons.person_outlined),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // -- Email (uses .email() convenience constructor) --
              FkTextField.email(
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
              FkTextField.password(
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
              FkTextField.password(
                name: 'confirmPassword',
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),

              // -- Terms & conditions checkbox --
              FkCheckboxField(
                name: 'terms',
                controller: _termsController,
                label: const Text('I agree to the Terms and Conditions'),
              ),
              const SizedBox(height: 24),

              // -- Submit button --
              // FkSubmitButton auto-disables when the form is invalid or
              // submitting, and shows a loading indicator during submission.
              FkSubmitButton(
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
