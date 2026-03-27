import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkAutovalidateMode.onSubmit', () {
    testWidgets('shows errors after a failed submit attempt', (tester) async {
      final formController = FkFormController();
      final emailController = FkFieldController<String>(
        validators: [Fk.required<String>()],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FkForm(
            controller: formController,
            autovalidateMode: FkAutovalidateMode.onSubmit,
            child: Column(
              children: [
                FkTextField(
                  name: 'email',
                  controller: emailController,
                ),
                FkSubmitButton(
                  onSubmit: (controller) async {
                    await controller.submit((values) async {});
                  },
                ),
              ],
            ),
          ),
        ),
      ));

      // Initially, no error should be shown (onSubmit mode = hidden until submit)
      expect(find.text('This field is required'), findsNothing);

      // Tap submit with empty field — should trigger validation
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // After failed submit, error should now be visible
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('does not show errors before submit attempt', (tester) async {
      final formController = FkFormController();
      final emailController = FkFieldController<String>(
        validators: [Fk.required<String>()],
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FkForm(
            controller: formController,
            autovalidateMode: FkAutovalidateMode.onSubmit,
            child: Column(
              children: [
                FkTextField(
                  name: 'email',
                  controller: emailController,
                ),
              ],
            ),
          ),
        ),
      ));

      // Touch the field and leave it empty
      emailController.markTouched();
      await tester.pump();

      // Even though field is touched and invalid, onSubmit mode should NOT show error
      expect(find.text('This field is required'), findsNothing);
    });
  });
}
