import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

/// A minimal country list with unique dial codes, used to avoid the Flutter
/// DropdownButton assertion that fires when two items share the same value.
/// The default [_kDefaultCountries] list contains both '+1 (US)' and '+1 (CA)',
/// which triggers the assertion in tests.
const _uniqueCountries = [
  (code: '+1', name: 'US'),
  (code: '+44', name: 'UK'),
  (code: '+61', name: 'AU'),
  (code: '+91', name: 'IN'),
];

void main() {
  group('BfPhoneField', () {
    testWidgets('renders a TextField for phone input', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            labelText: 'Phone',
            countries: _uniqueCountries,
          ),
        ),
      );

      expect(find.text('Phone'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(controller.dispose);
    });

    testWidgets('typing updates controller value', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            countries: _uniqueCountries,
          ),
        ),
      );

      // The phone field renders a single TextField; the country code picker
      // is a DropdownButton prefix inside that TextField's decoration.
      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();

      expect(controller.value, isNotNull);
      expect(controller.value, isNotEmpty);

      addTearDown(controller.dispose);
    });

    testWidgets('displays default country code', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            defaultCountryCode: '+44',
            countries: _uniqueCountries,
          ),
        ),
      );

      // The selected dial code is shown as the DropdownButton value.
      expect(find.textContaining('+44'), findsWidgets);

      addTearDown(controller.dispose);
    });

    testWidgets('uses +1 as the default country code when none is specified',
        (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            countries: _uniqueCountries,
          ),
        ),
      );

      expect(find.textContaining('+1'), findsWidgets);

      addTearDown(controller.dispose);
    });

    testWidgets('controller value includes dial code prefix', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            defaultCountryCode: '+1',
            countries: _uniqueCountries,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '2025551234');
      await tester.pump();

      expect(controller.value, startsWith('+1'));

      addTearDown(controller.dispose);
    });

    testWidgets('disabled field does not accept input', (tester) async {
      final controller = BfFieldController<String>();

      await tester.pumpWidget(
        buildTestForm(
          child: BfPhoneField(
            name: 'phone',
            controller: controller,
            enabled: false,
            countries: _uniqueCountries,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      addTearDown(controller.dispose);
    });
  });
}
