import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkWizard', () {
    testWidgets('renders first step initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkWizard(
              fields: {
                'name': FkFieldConfig<String>.text(
                  label: 'Name',
                  validators: [Fk.required()],
                ),
                'email': FkFieldConfig<String>.email(
                  label: 'Email',
                  validators: [Fk.required()],
                ),
              },
              steps: [
                FkWizardStep(title: 'Step 1', fieldNames: ['name']),
                FkWizardStep(title: 'Step 2', fieldNames: ['email']),
              ],
              builder: (context, scope, wizard) {
                return Column(
                  children: [
                    Text('Step: ${wizard.currentStep}'),
                    if (wizard.currentStep == 0) scope.text('name'),
                    if (wizard.currentStep == 1) scope.email('email'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Step: 0'), findsOneWidget);
      expect(find.byType(FkTextField), findsOneWidget);
    });

    testWidgets('next/back buttons navigate between steps',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkWizard(
              fields: {
                'name': FkFieldConfig<String>.text(label: 'Name'),
                'email': FkFieldConfig<String>.email(label: 'Email'),
              },
              steps: [
                FkWizardStep(title: 'Step 1', fieldNames: ['name']),
                FkWizardStep(title: 'Step 2', fieldNames: ['email']),
              ],
              builder: (context, scope, wizard) {
                return Column(
                  children: [
                    Text('Step: ${wizard.currentStep}'),
                    if (wizard.currentStep == 0) scope.text('name'),
                    if (wizard.currentStep == 1) scope.email('email'),
                    ElevatedButton(
                      onPressed: wizard.goNext,
                      child: const Text('Next'),
                    ),
                    ElevatedButton(
                      onPressed: wizard.goBack,
                      child: const Text('Back'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Step: 0'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('Step: 1'), findsOneWidget);

      await tester.tap(find.text('Back'));
      await tester.pump();
      expect(find.text('Step: 0'), findsOneWidget);
    });

    testWidgets('validates current step before advancing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FkWizard(
              fields: {
                'name': FkFieldConfig<String>.text(
                  label: 'Name',
                  validators: [Fk.required()],
                ),
                'email': FkFieldConfig<String>.email(label: 'Email'),
              },
              steps: [
                FkWizardStep(title: 'Step 1', fieldNames: ['name']),
                FkWizardStep(title: 'Step 2', fieldNames: ['email']),
              ],
              builder: (context, scope, wizard) {
                return Column(
                  children: [
                    Text('Step: ${wizard.currentStep}'),
                    if (wizard.currentStep == 0) scope.text('name'),
                    if (wizard.currentStep == 1) scope.email('email'),
                    ElevatedButton(
                      onPressed: () async {
                        await wizard.validateAndGoNext(scope.formController);
                      },
                      child: const Text('Next'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Name field is empty and required, so validateAndGoNext should not advance.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Step: 0'), findsOneWidget);
    });
  });
}
