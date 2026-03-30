import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfDateRangeField', () {
    testWidgets('renders with label text', (tester) async {
      // Given: a date range field controller
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a BfDateRangeField with label
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            labelText: 'Stay Duration',
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: the label text is displayed
      expect(find.text('Stay Duration'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('renders an InputDecorator', (tester) async {
      // Given: a date range field controller
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a BfDateRangeField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: an InputDecorator is present
      expect(find.byType(InputDecorator), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('tapping opens date range picker dialog', (tester) async {
      // Given: a date range field controller
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a BfDateRangeField and tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Tap on the InputDecorator to open the date range picker
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Then: a dialog (date range picker) should appear
      expect(find.byType(Dialog), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('displays date range when value is set', (tester) async {
      // Given: a date range field with initial value
      final controller = BfFieldController<DateTimeRange>(
        initialValue: DateTimeRange(
          start: DateTime(2025, 1, 10),
          end: DateTime(2025, 1, 20),
        ),
      );

      // When: we render the BfDateRangeField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: the date range is displayed
      expect(find.text('2025-01-10 — 2025-01-20'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('displays only label when no range is set', (tester) async {
      // Given: a date range field controller with no initial value
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a BfDateRangeField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            labelText: 'Select Range',
            hintText: 'Pick dates',
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Then: the label is shown but no range text
      expect(find.text('Select Range'), findsOneWidget);
      expect(find.text('Pick dates'), findsOneWidget);
      expect(find.byType(Text), findsWidgets);

      addTearDown(controller.dispose);
    });

    testWidgets('opens date range picker when tapped', (tester) async {
      // Given: a date range field controller
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a BfDateRangeField and tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Tap to open the date range picker
      await tester.tap(find.byType(InputDecorator));
      await tester.pumpAndSettle();

      // Then: a date range picker dialog appears
      expect(find.byType(Dialog), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('respects date range constraints', (tester) async {
      // Given: a date range field with a specific range constraint
      final controller = BfFieldController<DateTimeRange>(
        initialValue: DateTimeRange(
          start: DateTime(2025, 6, 1),
          end: DateTime(2025, 6, 15),
        ),
      );

      // When: we render the BfDateRangeField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2025, 1, 1),
            lastDate: DateTime(2025, 12, 31),
          ),
        ),
      );

      // Then: the range is displayed within the constraints
      expect(find.text('2025-06-01 — 2025-06-15'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('does not open picker when disabled', (tester) async {
      // Given: a disabled date range field controller
      final controller = BfFieldController<DateTimeRange>();

      // When: we render a disabled BfDateRangeField and try to tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
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

      // Then: no date picker dialog should appear
      expect(find.byType(Dialog), findsNothing);

      addTearDown(controller.dispose);
    });

    testWidgets('shows error text when validation fails', (tester) async {
      // Given: a date range field with a validator that always fails
      final controller = BfFieldController<DateTimeRange>(
        validators: [
          _AlwaysInvalidRangeValidator(),
        ],
      );

      // When: we render the BfDateRangeField with autovalidation
      await tester.pumpWidget(
        buildTestForm(
          autovalidateMode: BfAutovalidateMode.always,
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Trigger validation by setting a value and validating
      controller.value = DateTimeRange(
        start: DateTime(2025, 1, 1),
        end: DateTime(2025, 1, 10),
      );
      await tester.pump();

      // Then: the error text is displayed
      expect(find.text('Range is required'), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('syncs with external controller value changes', (tester) async {
      // Given: a date range field with initial value
      final controller = BfFieldController<DateTimeRange>(
        initialValue: DateTimeRange(
          start: DateTime(2025, 2, 1),
          end: DateTime(2025, 2, 10),
        ),
      );

      // When: we render the BfDateRangeField
      await tester.pumpWidget(
        buildTestForm(
          child: BfDateRangeField(
            name: 'stay',
            controller: controller,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          ),
        ),
      );

      // Verify initial range is shown
      expect(find.text('2025-02-01 — 2025-02-10'), findsOneWidget);

      // When: the controller value is changed externally
      controller.value = DateTimeRange(
        start: DateTime(2025, 3, 1),
        end: DateTime(2025, 3, 15),
      );
      await tester.pump();

      // Then: the new range is displayed
      expect(find.text('2025-03-01 — 2025-03-15'), findsOneWidget);

      addTearDown(controller.dispose);
    });
  });
}

/// A validator that always fails for DateTimeRange fields.
class _AlwaysInvalidRangeValidator extends BfValidator<DateTimeRange> {
  const _AlwaysInvalidRangeValidator();

  @override
  BfValidationResult? validate(DateTimeRange? value, [BfValidationContext? context]) {
    return const BfValidationResult('Range is required');
  }
}
