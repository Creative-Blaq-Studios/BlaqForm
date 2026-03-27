import 'package:flutter/material.dart';
import 'package:formkit/formkit.dart';

/// The same signup form as [SignupFormExample], but rewritten with
/// [FkFormBuilder] to show how much boilerplate it eliminates.
///
/// No StatefulWidget, no manual controller creation, no dispose — just a
/// declarative fields map and a builder callback.
class BuilderSignupFormExample extends StatelessWidget {
  const BuilderSignupFormExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup (FkFormBuilder)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FkFormBuilder(
          fields: {
            'name': FkFieldConfig<String>.text(
              label: 'Full Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outlined,
              validators: [Fk.required(message: 'Please enter your name')],
            ),
            'email': FkFieldConfig<String>.email(
              label: 'Email',
              hint: 'you@example.com',
              prefixIcon: Icons.email_outlined,
              validators: [Fk.required(), Fk.email()],
            ),
            'password': FkFieldConfig<String>.password(
              label: 'Password',
              hint: 'At least 8 characters',
              prefixIcon: Icons.lock_outlined,
              validators: [Fk.required(), Fk.minLength(8)],
            ),
            'confirmPassword': FkFieldConfig<String>.password(
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              prefixIcon: Icons.lock_outlined,
              validators: [
                Fk.required(),
                Fk.matchFields<String>('password',
                    message: 'Passwords do not match'),
              ],
            ),
            'terms': FkFieldConfig<bool>.checkbox(
              initialValue: false,
              label: 'I agree to the Terms and Conditions',
              validators: [
                Fk.equals<bool>(true, message: 'You must accept the terms'),
              ],
            ),
          },
          onSubmit: (values) async {
            await Future.delayed(const Duration(seconds: 2));
            debugPrint('Signup values: $values');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account created successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
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
      ),
    );
  }
}
