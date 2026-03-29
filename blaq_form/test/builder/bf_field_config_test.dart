import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFieldConfig', () {
    test('creates a text config with validators', () {
      final config = BfFieldConfig<String>.text(
        validators: [Bf.required(), Bf.email()],
        label: 'Email',
        hint: 'you@example.com',
      );

      expect(config.validators.length, 2);
      expect(config.label, 'Email');
      expect(config.hint, 'you@example.com');
      expect(config.initialValue, isNull);
      expect(config.fieldType, BfFieldType.text);
    });

    test('creates a password config', () {
      final config = BfFieldConfig<String>.password(
        validators: [Bf.required(), Bf.minLength(8)],
        label: 'Password',
      );

      expect(config.fieldType, BfFieldType.password);
    });

    test('creates a checkbox config with initial value', () {
      final config = BfFieldConfig<bool>.checkbox(
        initialValue: false,
        label: 'I agree',
        validators: [Bf.equals<bool>(true, message: 'Must accept')],
      );

      expect(config.fieldType, BfFieldType.checkbox);
      expect(config.initialValue, false);
    });

    test('creates a dropdown config with options', () {
      final config = BfFieldConfig<String>.dropdown(
        label: 'Country',
        options: ['US', 'UK', 'CA'],
        optionLabels: {
          'US': 'United States',
          'UK': 'United Kingdom',
          'CA': 'Canada',
        },
        validators: [Bf.required()],
      );

      expect(config.fieldType, BfFieldType.dropdown);
      expect(config.options, hasLength(3));
    });

    test('creates a date config', () {
      final config = BfFieldConfig<DateTime>.date(
        label: 'Birthday',
        validators: [Bf.required<DateTime>()],
      );

      expect(config.fieldType, BfFieldType.date);
    });

    test('buildController creates an BfFieldController with matching validators',
        () {
      final config = BfFieldConfig<String>.text(
        initialValue: 'hello',
        validators: [Bf.required()],
      );

      final controller = config.buildController();
      expect(controller.value, 'hello');
      // Validators are applied — clearing value should produce error
      controller.value = '';
      expect(controller.error, isNotNull);
      controller.dispose();
    });
  });
}
