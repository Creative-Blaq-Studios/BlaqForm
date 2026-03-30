import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfCheckboxGroupField', () {
    testWidgets('renders checkbox tiles for each option', (tester) async {
      // Given: a checkbox group field controller
      final controller = BfFieldController<List<String>>(initialValue: []);

      // When: we render a BfCheckboxGroupField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCheckboxGroupField<String>(
            name: 'tags',
            controller: controller,
            options: const ['Flutter', 'Dart', 'Firebase'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // Then: checkbox list tiles are rendered for each option
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('tapping a checkbox adds to controller value', (tester) async {
      // Given: a checkbox group field controller with empty initial value
      final controller = BfFieldController<List<String>>(initialValue: []);

      await tester.pumpWidget(
        buildTestForm(
          child: BfCheckboxGroupField<String>(
            name: 'tags',
            controller: controller,
            options: const ['Flutter', 'Dart', 'Firebase'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // When: the user taps on 'Flutter' checkbox
      await tester.tap(find.text('Flutter'));
      await tester.pump();

      // Then: the controller value includes 'Flutter'
      expect(controller.value, contains('Flutter'));

      // When: the user taps on 'Dart' checkbox
      await tester.tap(find.text('Dart'));
      await tester.pump();

      // Then: the controller value contains both selections
      expect(controller.value, containsAll(['Flutter', 'Dart']));

      addTearDown(controller.dispose);
    });

    testWidgets('tapping again removes from controller value', (tester) async {
      // Given: a checkbox group field with one initially selected item
      final controller = BfFieldController<List<String>>(
        initialValue: ['Flutter'],
      );

      await tester.pumpWidget(
        buildTestForm(
          child: BfCheckboxGroupField<String>(
            name: 'tags',
            controller: controller,
            options: const ['Flutter', 'Dart'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // Verify initial state
      expect(controller.value, contains('Flutter'));

      // When: the user taps on 'Flutter' checkbox again
      await tester.tap(find.text('Flutter'));
      await tester.pump();

      // Then: the item is removed from the controller value
      expect(controller.value, isNot(contains('Flutter')));

      addTearDown(controller.dispose);
    });

    testWidgets('registers with form and marks touched on toggle',
        (tester) async {
      // Given: a checkbox group field and form controller
      final fieldController = BfFieldController<List<String>>(
        initialValue: [],
      );
      final formController = BfFormController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BfForm(
              controller: formController,
              autovalidateMode: BfAutovalidateMode.onUserInteraction,
              child: BfCheckboxGroupField<String>(
                name: 'options',
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

      // When: the user toggles a checkbox
      await tester.tap(find.text('B'));
      await tester.pump();

      // Then: the field is marked as touched
      expect(fieldController.isTouched, isTrue);
      expect(fieldController.value, contains('B'));

      addTearDown(fieldController.dispose);
      addTearDown(formController.dispose);
    });
  });
}
