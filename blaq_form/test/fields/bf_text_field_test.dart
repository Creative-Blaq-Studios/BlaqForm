import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfTextField', () {
    testWidgets('renders a TextField', (tester) async {
      // Given: a text field controller
      final controller = BfFieldController<String>(initialValue: '');

      // When: we render an BfTextField
      await tester.pumpWidget(
        buildTestForm(
          child: BfTextField(name: 'username', controller: controller),
        ),
      );

      // Then: a TextField is rendered
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('updates controller value on text input', (tester) async {
      // Given: a text field controller with empty initial value
      final controller = BfFieldController<String>(initialValue: '');

      await tester.pumpWidget(
        buildTestForm(
          child: BfTextField(name: 'username', controller: controller),
        ),
      );

      // When: the user enters text
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      // Then: the controller value is updated
      expect(controller.value, equals('hello'));

      addTearDown(controller.dispose);
    });

    testWidgets(
      'shows error text when controller has error and field is touched',
      (tester) async {
        // Given: a text field with a validator that always fails
        final controller = BfFieldController<String>(
          initialValue: '',
          validators: [const AlwaysInvalidValidator('Name is required')],
        );

        await tester.pumpWidget(
          buildTestForm(
            autovalidateMode: BfAutovalidateMode.onUserInteraction,
            child: BfTextField(name: 'name', controller: controller),
          ),
        );

        // Error should not show before interaction
        expect(find.text('Name is required'), findsNothing);

        // When: trigger a value change so sync validation runs, then mark touched
        controller.value = 'a';
        controller.markTouched();
        await tester.pump();

        // Then: the error text is displayed
        expect(find.text('Name is required'), findsOneWidget);

        addTearDown(controller.dispose);
      },
    );

    testWidgets('does not show error when autovalidateMode is disabled', (
      tester,
    ) async {
      // Given: a text field with a failing validator and disabled autovalidation
      final controller = BfFieldController<String>(
        initialValue: '',
        validators: [const AlwaysInvalidValidator('Name is required')],
      );

      await tester.pumpWidget(
        buildTestForm(
          autovalidateMode: BfAutovalidateMode.disabled,
          child: BfTextField(name: 'name', controller: controller),
        ),
      );

      // When: the user interacts with the field
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      controller.markTouched();
      await tester.pump();

      // Then: no error text is displayed
      expect(find.text('Name is required'), findsNothing);

      addTearDown(controller.dispose);
    });

    testWidgets('syncs with external controller value changes', (tester) async {
      // Given: a text field with a controller
      final controller = BfFieldController<String>(initialValue: 'initial');

      await tester.pumpWidget(
        buildTestForm(
          child: BfTextField(name: 'field', controller: controller),
        ),
      );

      // Verify initial value is shown
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('initial'));

      // When: the controller value is changed externally
      controller.value = 'updated externally';
      await tester.pump();

      // Then: the TextField reflects the new value
      final updatedTextField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedTextField.controller!.text, equals('updated externally'));

      addTearDown(controller.dispose);
    });

    testWidgets('calls markTouched on focus lost', (tester) async {
      // Given: a text field and another focusable widget
      final controller = BfFieldController<String>(initialValue: '');

      await tester.pumpWidget(
        buildTestForm(
          child: Column(
            children: [
              BfTextField(name: 'first', controller: controller),
              const TextField(), // another field to take focus
            ],
          ),
        ),
      );

      // The field should not be touched initially
      expect(controller.isTouched, isFalse);

      // When: we focus the BfTextField then focus the other TextField
      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      // Move focus to the other text field
      await tester.tap(find.byType(TextField).last);
      await tester.pump();

      // Then: the controller is marked as touched
      expect(controller.isTouched, isTrue);

      addTearDown(controller.dispose);
    });
  });
}
