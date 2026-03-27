import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('FkSwitchField', () {
    testWidgets('renders a SwitchListTile', (tester) async {
      // Given: a bool controller
      final controller = FkFieldController<bool>(initialValue: false);

      // When: we render an FkSwitchField
      await tester.pumpWidget(
        buildTestForm(
          child: FkSwitchField(
            name: 'toggle',
            controller: controller,
            label: const Text('Enable notifications'),
          ),
        ),
      );

      // Then: a SwitchListTile is rendered
      expect(find.byType(SwitchListTile), findsOneWidget);
      expect(find.text('Enable notifications'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('toggles controller value on tap', (tester) async {
      // Given: a bool controller with initial value false
      final controller = FkFieldController<bool>(initialValue: false);

      await tester.pumpWidget(
        buildTestForm(
          child: FkSwitchField(
            name: 'toggle',
            controller: controller,
            label: const Text('Toggle'),
          ),
        ),
      );

      // Verify initial state
      expect(controller.value, isFalse);

      // When: the user taps the switch
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();

      // Then: the controller value is toggled to true
      expect(controller.value, isTrue);

      addTearDown(controller.dispose);
    });

    testWidgets('shows error when shouldShowError is true', (tester) async {
      // Given: a switch field with a validator that always fails
      final controller = FkFieldController<bool>(
        initialValue: false,
        validators: [const AlwaysInvalidBoolValidator('Must accept terms')],
      );

      await tester.pumpWidget(
        buildTestForm(
          autovalidateMode: FkAutovalidateMode.always,
          child: FkSwitchField(
            name: 'terms',
            controller: controller,
            label: const Text('Accept terms'),
          ),
        ),
      );

      // When: trigger validation by setting a value
      controller.value = false;
      await tester.pump();

      // Then: error text is displayed
      expect(find.text('Must accept terms'), findsOneWidget);

      addTearDown(controller.dispose);
    });
  });
}
