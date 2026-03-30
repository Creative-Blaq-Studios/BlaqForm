import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfAutovalidateMode.onSubmit', () {
    testWidgets('shows errors after a failed submit attempt', (tester) async {
      final formController = BfFormController();
      final emailController = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              autovalidateMode: BfAutovalidateMode.onSubmit,
              child: Column(
                children: [
                  BfTextField(name: 'email', controller: emailController),
                  // disableWhenInvalid: false so the button is always tappable
                  // in onSubmit mode — the form gates submission internally.
                  BfSubmitButton(
                    disableWhenInvalid: false,
                    onSubmit: (controller) async {
                      await controller.submit((values) async {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Initially, no error should be shown (onSubmit mode = hidden until submit)
      expect(find.text('This field is required'), findsNothing);

      // Tap submit with empty field — should trigger validation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // After failed submit, error should now be visible
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('does not show errors before submit attempt', (tester) async {
      final formController = BfFormController();
      final emailController = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              autovalidateMode: BfAutovalidateMode.onSubmit,
              child: Column(
                children: [
                  BfTextField(name: 'email', controller: emailController),
                ],
              ),
            ),
          ),
        ),
      );

      // Touch the field and leave it empty
      emailController.markTouched();
      await tester.pump();

      // Even though field is touched and invalid, onSubmit mode should NOT show error
      expect(find.text('This field is required'), findsNothing);
    });
  });
}
