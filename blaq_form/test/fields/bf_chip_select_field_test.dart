import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfChipSelectField', () {
    testWidgets('renders filter chips for each option', (tester) async {
      // Given: a chip select field controller
      final controller = BfFieldController<List<String>>(initialValue: []);

      // When: we render a BfChipSelectField
      await tester.pumpWidget(
        buildTestForm(
          child: BfChipSelectField<String>(
            name: 'skills',
            controller: controller,
            options: const ['Flutter', 'Dart', 'Go'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // Then: filter chips are rendered for each option
      expect(find.byType(FilterChip), findsNWidgets(3));
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('tapping a chip toggles selection in controller value',
        (tester) async {
      // Given: a chip select field controller with empty initial value
      final controller = BfFieldController<List<String>>(initialValue: []);

      await tester.pumpWidget(
        buildTestForm(
          child: BfChipSelectField<String>(
            name: 'skills',
            controller: controller,
            options: const ['Flutter', 'Dart'],
            labelBuilder: (o) => o,
          ),
        ),
      );

      // When: the user taps on the 'Flutter' chip
      await tester.tap(find.text('Flutter'));
      await tester.pump();

      // Then: the chip is selected and added to controller value
      expect(controller.value, contains('Flutter'));

      // When: the user taps on 'Flutter' chip again
      await tester.tap(find.text('Flutter'));
      await tester.pump();

      // Then: the chip is deselected and removed from controller value
      expect(controller.value, isNot(contains('Flutter')));

      addTearDown(controller.dispose);
    });

    testWidgets('renders label text when provided', (tester) async {
      // Given: a chip select field with a label text
      final controller = BfFieldController<List<String>>(initialValue: []);

      await tester.pumpWidget(
        buildTestForm(
          child: BfChipSelectField<String>(
            name: 'skills',
            controller: controller,
            options: const ['A'],
            labelBuilder: (o) => o,
            labelText: 'Pick skills',
          ),
        ),
      );

      // When: the widget renders
      // Then: the label text is displayed
      expect(find.text('Pick skills'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('registers with form and marks touched on selection',
        (tester) async {
      // Given: a chip select field and form controller
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
              child: BfChipSelectField<String>(
                name: 'tags',
                controller: fieldController,
                options: const ['X', 'Y', 'Z'],
                labelBuilder: (o) => o,
              ),
            ),
          ),
        ),
      );

      // The field should not be touched initially
      expect(fieldController.isTouched, isFalse);

      // When: the user taps a chip
      await tester.tap(find.text('Y'));
      await tester.pump();

      // Then: the field is marked as touched
      expect(fieldController.isTouched, isTrue);
      expect(fieldController.value, contains('Y'));

      addTearDown(fieldController.dispose);
      addTearDown(formController.dispose);
    });
  });
}
