import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_scaffold.dart';

class WizardOnboardingExample extends StatelessWidget {
  const WizardOnboardingExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return BrandScaffold(
      notifier: notifier,
      title: 'BfWizard',
      body: BfWizard(
        fields: {
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
          'name': BfFieldConfig<String>.text(
            label: 'Display Name',
            hint: 'How should we call you?',
            prefixIcon: Icons.person_outlined,
            validators: [Bf.required()],
          ),
          'bio': BfFieldConfig<String>.text(
            label: 'Bio',
            hint: 'Tell us about yourself',
            prefixIcon: Icons.edit_outlined,
          ),
        },
        steps: const [
          BfWizardStep(title: 'Account', fieldNames: ['email', 'password']),
          BfWizardStep(title: 'Profile', fieldNames: ['name', 'bio']),
          BfWizardStep(title: 'Confirm', fieldNames: []),
        ],
        onComplete: (values) async {
          await Future.delayed(const Duration(seconds: 2));
        },
        builder: (context, scope, wizard) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _BrandStepProgress(wizard: wizard),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: _WizardStepContent(scope: scope, wizard: wizard),
                  ),
                ),
                const SizedBox(height: 16),
                _WizardNavigation(scope: scope, wizard: wizard),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BrandStepProgress extends StatelessWidget {
  const _BrandStepProgress({required this.wizard});

  final BfWizardController wizard;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wizard,
      builder: (context, _) {
        return Row(
          children: List.generate(wizard.stepCount, (i) {
            final isActive = i == wizard.currentStep;
            final isDone = i < wizard.currentStep;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isDone || isActive
                          ? const Color(0xFFFF6B00)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (i < wizard.stepCount - 1) const SizedBox(width: 2),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _WizardStepContent extends StatelessWidget {
  const _WizardStepContent({required this.scope, required this.wizard});

  final BfFormBuilderScope scope;
  final BfWizardController wizard;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wizard,
      builder: (context, _) {
        switch (wizard.currentStep) {
          case 0:
            return _StepBody(
              step: '01',
              title: 'Create your account',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  scope.email('email'),
                  const SizedBox(height: 16),
                  scope.password('password'),
                ],
              ),
            );
          case 1:
            return _StepBody(
              step: '02',
              title: 'Set up your profile',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  scope.text('name'),
                  const SizedBox(height: 16),
                  scope.text('bio', maxLines: 3),
                ],
              ),
            );
          case 2:
            return _StepBody(
              step: '03',
              title: 'You\'re all set',
              child: _ReviewCard(scope: scope),
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.step,
    required this.title,
    required this.child,
  });

  final String step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '// step $step',
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 10,
            color: Color(0xFFFF6B00),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.02,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.scope});

  final BfFormBuilderScope scope;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final email = scope.controller<String>('email').value ?? '(not provided)';
    final name = scope.controller<String>('name').value ?? '(not provided)';
    final bio = scope.controller<String>('bio').value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          _ReviewRow(label: 'Email', value: email),
          Divider(color: cs.outline, height: 24),
          _ReviewRow(label: 'Name', value: name),
          if (bio != null && bio.isNotEmpty) ...[
            Divider(color: cs.outline, height: 24),
            _ReviewRow(label: 'Bio', value: bio),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.45),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _WizardNavigation extends StatelessWidget {
  const _WizardNavigation({required this.scope, required this.wizard});

  final BfFormBuilderScope scope;
  final BfWizardController wizard;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wizard,
      builder: (context, _) {
        return Row(
          children: [
            if (wizard.canGoBack)
              OutlinedButton(
                onPressed: wizard.goBack,
                child: const Text('Back'),
              ),
            const Spacer(),
            if (wizard.isLastStep)
              scope.submitButton(
                'Complete',
                onSubmit: (values) async {
                  await scope.onSubmit?.call(values);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Onboarding complete!')),
                    );
                    Navigator.of(context).pop();
                  }
                },
              )
            else
              ElevatedButton(
                onPressed: () => wizard.validateAndGoNext(scope.formController),
                child: const Text('Next'),
              ),
          ],
        );
      },
    );
  }
}
