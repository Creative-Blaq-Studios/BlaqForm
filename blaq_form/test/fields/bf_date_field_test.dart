import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfDateField', () {
    testWidgets('renders with label and hint text', (tester) async {
      // Given: a date field controller
      final controller = BfFieldController<DateTime>();

      // When: we render a BfDateField with label and hint
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            labelText: 'Date of Birth',
            hintText: 'Pick a date',
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: the label and hint text are displayed
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Pick a date'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('renders an InputDecorator', (tester) async {
      // Given: a date field controller
      final controller = BfFieldController<DateTime>();

      // When: we render a BfDateField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: an InputDecorator is present
      expect(find.byType(InputDecorator), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('tapping opens date picker dialog', (tester) async {
      // Given: a date field controller
      final controller = BfFieldController<DateTime>();

      // When: we render a BfDateField and tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Tap on the InputDecorator to open the date picker
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Then: a DatePickerDialog should appear
      expect(find.byType(DatePickerDialog), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('displays formatted date when value is set', (tester) async {
      // Given: a date field with an initial date value
      final controller = BfFieldController<DateTime>(
        initialValue: DateTime(2025, 6, 15),
      );

      // When: we render the BfDateField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            dateFormat: 'yyyy-MM-dd',
          ),
        ),
      );

      // Then: the date is displayed in the expected format
      expect(find.text('2025-06-15'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('uses default date format when not specified', (tester) async {
      // Given: a date field with initial value and no custom format
      final controller = BfFieldController<DateTime>(
        initialValue: DateTime(2025, 3, 30),
      );

      // When: we render the BfDateField without dateFormat
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: the default format (yyyy-MM-dd) is used
      expect(find.text('2025-03-30'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('opens date picker when tapped and allows interaction', (tester) async {
      // Given: a date field controller
      final controller = BfFieldController<DateTime>();

      // When: we render a BfDateField and tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Tap to open the date picker
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Then: a date picker dialog appears
      expect(find.byType(DatePickerDialog), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('syncs with external controller value changes', (tester) async {
      // Given: a date field with initial value
      final controller = BfFieldController<DateTime>(
        initialValue: DateTime(2025, 3, 15),
      );

      // When: we render the BfDateField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Verify initial value is shown
      expect(find.text('2025-03-15'), findsOneWidget);

      // When: the controller value is changed externally
      controller.value = DateTime(2025, 12, 25);
      await tester.pump();

      // Then: the new value is displayed
      expect(find.text('2025-12-25'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('does not open picker when disabled', (tester) async {
      // Given: a disabled date field controller
      final controller = BfFieldController<DateTime>();

      // When: we render a disabled BfDateField and try to tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            enabled: false,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Tap on the InputDecorator
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Then: no DatePickerDialog should appear
      expect(find.byType(DatePickerDialog), findsNothing);

      addTearDown(controller.dispose);
    });

    testWidgets('uses custom dateFormat with different token combinations', (tester) async {
      // Given: a date field with a custom format
      final controller = BfFieldController<DateTime>(
        initialValue: DateTime(2025, 3, 5),
      );

      // When: we render the BfDateField with a different format
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateField(
            name: 'dob',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            dateFormat: 'dd/MM/yyyy',
          ),
        ),
      );

      // Then: the date is displayed in the custom format
      expect(find.text('05/03/2025'), findsOneWidget);

      addTearDown(controller.dispose);
    });
  });
}
