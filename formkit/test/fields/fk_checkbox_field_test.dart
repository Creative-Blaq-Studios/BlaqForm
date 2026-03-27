import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkCheckboxField', () {
    testWidgets('renders a CheckboxListTile', (tester) async {
      // Given: a bool field controller
      final controller = FkFieldController<bool>(initialValue: false);

      // When: we render an FkCheckboxField
      await tester.pumpWidget(
        buildTestForm(
          child: FkCheckboxField(
            name: 'agree',
            controller: controller,
            label: const Text('I agree'),
          ),
        ),
      );

      // Then: a CheckboxListTile is rendered
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('I agree'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('toggles controller value on tap', (tester) async {
      // Given: a bool controller starting at false
      final controller = FkFieldController<bool>(initialValue: false);

      await tester.pumpWidget(
        buildTestForm(
          child: FkCheckboxField(
            name: 'agree',
            controller: controller,
            label: const Text('I agree'),
          ),
        ),
      );

      // Value should start as false
      expect(controller.value, isFalse);

      // When: the user taps the checkbox
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Then: the controller value toggles to true
      expect(controller.value, isTrue);

      // When: the user taps again
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();

      // Then: the controller value toggles back to false
      expect(controller.value, isFalse);

      addTearDown(controller.dispose);
    });

    testWidgets('shows error when shouldShowError is true', (tester) async {
      // Given: a checkbox with a validator that requires true
      final controller = FkFieldController<bool>(
        initialValue: false,
        validators: [const RequiredBoolValidator()],
      );

      await tester.pumpWidget(
        buildTestForm(
          autovalidateMode: FkAutovalidateMode.always,
          child: FkCheckboxField(
            name: 'agree',
            controller: controller,
            label: const Text('I agree'),
          ),
        ),
      );

      // When: validation runs (value is false, always mode)
      // Trigger validation by setting value
      controller.value = false;
      await tester.pump();

      // Then: the error text is displayed
      expect(find.text('This field is required'), findsOneWidget);

      addTearDown(controller.dispose);
    });
  });
}
