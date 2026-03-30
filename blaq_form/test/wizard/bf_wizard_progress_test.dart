import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfWizardProgress', () {
    testWidgets('renders step labels for each step', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'Account', fieldNames: ['email']),
          BfWizardStep(title: 'Profile', fieldNames: ['name']),
          BfWizardStep(title: 'Confirm', fieldNames: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(controller: wizard),
          ),
        ),
      );

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);

      wizard.dispose();
    });

    testWidgets('renders step number circles for each step', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'Step 1', fieldNames: []),
          BfWizardStep(title: 'Step 2', fieldNames: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(controller: wizard),
          ),
        ),
      );

      // Each step circle shows its 1-based number.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      wizard.dispose();
    });

    testWidgets('first step is active on initial render', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'First', fieldNames: []),
          BfWizardStep(title: 'Second', fieldNames: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(controller: wizard),
          ),
        ),
      );

      // currentStep == 0 on creation.
      expect(wizard.currentStep, 0);

      wizard.dispose();
    });

    testWidgets('rebuilds when wizard advances to next step', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'One', fieldNames: []),
          BfWizardStep(title: 'Two', fieldNames: []),
          BfWizardStep(title: 'Three', fieldNames: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(controller: wizard),
          ),
        ),
      );

      // Advance the wizard and confirm the widget rebuilds.
      wizard.goNext();
      await tester.pump();

      expect(wizard.currentStep, 1);
      // All labels are still visible after navigation.
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);

      wizard.dispose();
    });

    testWidgets('completed steps show a checkmark icon', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'Done', fieldNames: []),
          BfWizardStep(title: 'Active', fieldNames: []),
          BfWizardStep(title: 'Future', fieldNames: []),
        ],
      );

      // Advance so step 0 is completed.
      wizard.goNext();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(controller: wizard),
          ),
        ),
      );

      // Step 0 is completed — its circle renders a check icon.
      expect(find.byIcon(Icons.check), findsOneWidget);

      wizard.dispose();
    });

    testWidgets('accepts optional color and size parameters', (tester) async {
      final wizard = BfWizardController(
        steps: const [
          BfWizardStep(title: 'A', fieldNames: []),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfWizardProgress(
              controller: wizard,
              activeColor: Colors.red,
              inactiveColor: Colors.blueGrey,
              circleSize: 40.0,
              lineThickness: 3.0,
            ),
          ),
        ),
      );

      // Widget should render without throwing.
      expect(find.byType(BfWizardProgress), findsOneWidget);

      wizard.dispose();
    });
  });
}
