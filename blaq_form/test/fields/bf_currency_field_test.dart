import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfCurrencyField', () {
    testWidgets('renders a TextField with currency symbol', (tester) async {
      // Given: a currency field controller
      final controller = BfFieldController<double>();

      // When: we render a BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            labelText: 'Price',
            symbol: '\$',
          ),
        ),
      );

      // Then: a TextField is rendered with the label
      expect(find.text('Price'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('displays currency symbol as prefix', (tester) async {
      // Given: a currency field controller
      final controller = BfFieldController<double>();

      // When: we render a BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Then: the TextField is rendered with a prefix containing the symbol
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.prefixText, equals('\$'));

      addTearDown(controller.dispose);
    });

    testWidgets('typing updates controller with parsed double', (tester) async {
      // Given: a currency field controller
      final controller = BfFieldController<double>();

      // When: we render a BfCurrencyField and enter text
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Type a number
      await tester.enterText(find.byType(TextField), '42.50');
      await tester.pump();

      // Then: the controller value is updated with the parsed double
      expect(controller.value, isNotNull);
      expect(controller.value, closeTo(42.50, 0.01));

      addTearDown(controller.dispose);
    });

    testWidgets('displays initial value formatted with currency', (tester) async {
      // Given: a currency field with an initial value
      final controller = BfFieldController<double>(initialValue: 99.99);

      // When: we render the BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Then: the value is displayed formatted
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, contains('99'));

      addTearDown(controller.dispose);
    });

    testWidgets('formats value with thousand separators', (tester) async {
      // Given: a currency field with a large initial value
      final controller = BfFieldController<double>(initialValue: 1234567.89);

      // When: we render the BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Then: the value is displayed with thousand separators
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, contains(','));
      expect(textField.controller!.text, equals('1,234,567.89'));

      addTearDown(controller.dispose);
    });

    testWidgets('parses input with thousand separators', (tester) async {
      // Given: a currency field controller
      final controller = BfFieldController<double>();

      // When: we render a BfCurrencyField and type a formatted number
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Clear and type a formatted value
      await tester.enterText(find.byType(TextField), '1,234.56');
      await tester.pump();

      // Then: the controller value is correctly parsed
      expect(controller.value, closeTo(1234.56, 0.01));

      addTearDown(controller.dispose);
    });

    testWidgets('respects custom decimal places setting', (tester) async {
      // Given: a currency field with custom decimal places
      final controller = BfFieldController<double>(initialValue: 42.5);

      // When: we render the BfCurrencyField with decimalPlaces: 1
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
            decimalPlaces: 1,
          ),
        ),
      );

      // Then: the value is formatted with 1 decimal place
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('42.5'));

      addTearDown(controller.dispose);
    });

    testWidgets('marks field as touched on focus lost', (tester) async {
      // Given: a currency field controller
      final controller = BfFieldController<double>();

      // When: we render a BfCurrencyField and another field
      await tester.pumpWidget(
        buildTestForm(
          child: Column(
            children: [
              BfCurrencyField(
                name: 'price',
                controller: controller,
                symbol: '\$',
              ),
              const TextField(), // Another field to take focus
            ],
          ),
        ),
      );

      // Verify field is not touched initially
      expect(controller.isTouched, isFalse);

      // Tap the currency field
      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      // Move focus to the other text field
      await tester.tap(find.byType(TextField).last);
      await tester.pump();

      // Then: the currency field is marked as touched
      expect(controller.isTouched, isTrue);

      addTearDown(controller.dispose);
    });

    testWidgets('syncs with external controller value changes', (tester) async {
      // Given: a currency field with initial value
      final controller = BfFieldController<double>(initialValue: 100.00);

      // When: we render the BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Verify initial value is displayed
      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('100.00'));

      // When: the controller value is changed externally
      controller.value = 250.50;
      await tester.pump();

      // Then: the TextField reflects the new value
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('250.50'));

      addTearDown(controller.dispose);
    });

    testWidgets('respects custom thousand separator', (tester) async {
      // Given: a currency field with custom thousand separator
      final controller = BfFieldController<double>(initialValue: 1234567.89);

      // When: we render the BfCurrencyField with custom separator
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '€',
            thousandSeparator: ' ',
          ),
        ),
      );

      // Then: the value is displayed with the custom separator
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('1 234 567.89'));

      addTearDown(controller.dispose);
    });

    testWidgets('respects custom decimal separator', (tester) async {
      // Given: a currency field with custom decimal separator
      final controller = BfFieldController<double>(initialValue: 42.50);

      // When: we render the BfCurrencyField with custom decimal separator
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '€',
            decimalSeparator: ',',
          ),
        ),
      );

      // Then: the value is displayed with the custom decimal separator
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, equals('42,50'));

      addTearDown(controller.dispose);
    });

    testWidgets('does not open keyboard when disabled', (tester) async {
      // Given: a disabled currency field controller
      final controller = BfFieldController<double>();

      // When: we render a disabled BfCurrencyField and try to tap it
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            enabled: false,
            symbol: '\$',
          ),
        ),
      );

      // Tap on the TextField
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Then: the TextField is not enabled (no input possible)
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      addTearDown(controller.dispose);
    });

    testWidgets('clears value when set to null', (tester) async {
      // Given: a currency field with initial value
      final controller = BfFieldController<double>(initialValue: 99.99);

      // When: we render the BfCurrencyField
      await tester.pumpWidget(
        buildTestForm(
          child: BfCurrencyField(
            name: 'price',
            controller: controller,
            symbol: '\$',
          ),
        ),
      );

      // Verify initial value
      var textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isNotEmpty);

      // When: the controller value is set to null
      controller.value = null;
      await tester.pump();

      // Then: the TextField is empty
      textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);

      addTearDown(controller.dispose);
    });
  });
}
