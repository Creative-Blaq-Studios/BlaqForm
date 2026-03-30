import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfRadioGroupField', () {
    testWidgets('renders radio tiles for each option', (tester) async {
      // Given: a radio group field controller
      final controller = BfFieldController<String>();

      // When: we render a BfRadioGroupField
      await tester.pumpWidget(
        buildTestForm(
          child: BfRadioGroupField<String>(
            name: 'color',
            controller: controller,
            options: const ['Red', 'Green', 'Blue'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // Then: radio list tiles are rendered for each option
      expect(find.byType(RadioListTile<String>), findsNWidgets(3));
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('tapping a radio updates controller value', (tester) async {
      // Given: a radio group field controller with empty initial value
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfRadioGroupField<String>(
            name: 'color',
            controller: controller,
            options: const ['Red', 'Green', 'Blue'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // When: the user taps on 'Green' radio
      await tester.tap(find.text('Green'));
      await tester.pump();

      // Then: the controller value is updated to 'Green'
      expect(controller.value, equals('Green'));

      addTearDown(controller.dispose);
    });

    testWidgets('reflects controller value in selected radio', (tester) async {
      // Given: a radio group field with an initial value
      final controller = BfFieldController<String>(initialValue: 'Blue');

      await tester.pumpWidget(
        buildTestForm(
          child: BfRadioGroupField<String>(
            name: 'color',
            controller: controller,
            options: const ['Red', 'Green', 'Blue'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // When: the widget renders with an initial value
      // Then: the controller retains that value
      expect(controller.value, equals('Blue'));

      // Verify radio tiles are present
      expect(find.byType(RadioListTile<String>), findsNWidgets(3));

      addTearDown(controller.dispose);
    });

    testWidgets('registers with form and marks touched on selection',
        (tester) async {
      // Given: a radio group field and form controller
      final fieldController = BfFieldController<String>();
      final formController = BfFormController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              autovalidateMode: BfAutovalidateMode.onUserInteraction,
              child: BfRadioGroupField<String>(
                name: 'choice',
                controller: fieldController,
                options: const ['A', 'B', 'C'],
                labelBuilder: (o) => o,
              ),
            ),
          ),
        ),
      );

      // The field should not be touched initially
      expect(fieldController.isTouched, isFalse);

      // When: the user selects an option
      await tester.tap(find.text('B'));
      await tester.pump();

      // Then: the field is marked as touched
      expect(fieldController.isTouched, isTrue);
      expect(fieldController.value, equals('B'));

      addTearDown(fieldController.dispose);
      addTearDown(formController.dispose);
    });
  });
}
