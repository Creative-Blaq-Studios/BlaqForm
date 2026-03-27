import 'package:flutter/material.dart';
import 'package:formkit/formkit.dart';

/// A three-step onboarding wizard demonstrating [FkWizard],
/// [FkWizardProgress], and per-step validation.
///
/// Steps:
/// 1. **Account** — email and password
/// 2. **Profile** — name and bio
/// 3. **Confirm** — review summary with a submit button
class WizardOnboardingExample extends StatelessWidget {
  const WizardOnboardingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding (FkWizard)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FkWizard(
        fields: {
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
          'name': FkFieldConfig<String>.text(
            label: 'Display Name',
            hint: 'How should we call you?',
            prefixIcon: Icons.person_outlined,
            validators: [Fk.required()],
          ),
          'bio': FkFieldConfig<String>.text(
            label: 'Bio',
            hint: 'Tell us about yourself',
            prefixIcon: Icons.edit_outlined,
          ),
        },
        steps: [
          const FkWizardStep(
            title: 'Account',
            fieldNames: ['email', 'password'],
          ),
          const FkWizardStep(
            title: 'Profile',
            fieldNames: ['name', 'bio'],
          ),
          const FkWizardStep(
            title: 'Confirm',
            fieldNames: [],
          ),
        ],
        onComplete: (values) async {
          await Future.delayed(const Duration(seconds: 2));
          debugPrint('Onboarding values: $values');
        },
        builder: (context, scope, wizard) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // -- Progress indicator --
                FkWizardProgress(controller: wizard),
                const SizedBox(height: 32),

                // -- Step content --
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildStepContent(context, scope, wizard),
                  ),
                ),

                // -- Navigation buttons --
                const SizedBox(height: 16),
                _buildNavigation(context, scope, wizard),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildStepContent(
    BuildContext context,
    FkFormBuilderScope scope,
    FkWizardController wizard,
  ) {
    switch (wizard.currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            scope.email('email'),
            const SizedBox(height: 16),
            scope.password('password'),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set up your profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            scope.text('name'),
            const SizedBox(height: 16),
            scope.text('bio', maxLines: 3),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You\'re all set!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Review your information and tap Complete to finish.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _reviewRow('Email', scope.controller<String>('email').value),
                    const Divider(),
                    _reviewRow('Name', scope.controller<String>('name').value),
                    const Divider(),
                    _reviewRow('Bio', scope.controller<String>('bio').value),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static Widget _reviewRow(String label, dynamic value) {
    final display = (value == null || value.toString().isEmpty)
        ? '(not provided)'
        : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(display)),
        ],
      ),
    );
  }

  static Widget _buildNavigation(
    BuildContext context,
    FkFormBuilderScope scope,
    FkWizardController wizard,
  ) {
    return Row(
      children: [
        // Back button (hidden on first step)
        if (wizard.canGoBack)
          OutlinedButton(
            onPressed: wizard.goBack,
            child: const Text('Back'),
          ),
        const Spacer(),

        // Next or Complete
        if (wizard.isLastStep)
          scope.submitButton(
            'Complete',
            onSubmit: (values) async {
              await scope.onSubmit?.call(values);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Onboarding complete!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
          )
        else
          FilledButton(
            onPressed: () =>
                wizard.validateAndGoNext(scope.formController),
            child: const Text('Next'),
          ),
      ],
    );
  }
}
