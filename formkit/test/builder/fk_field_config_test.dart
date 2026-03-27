import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkFieldConfig', () {
    test('creates a text config with validators', () {
      final config = FkFieldConfig<String>.text(
        validators: [Fk.required(), Fk.email()],
        label: 'Email',
        hint: 'you@example.com',
      );

      expect(config.validators.length, 2);
      expect(config.label, 'Email');
      expect(config.hint, 'you@example.com');
      expect(config.initialValue, isNull);
      expect(config.fieldType, FkFieldType.text);
    });

    test('creates a password config', () {
      final config = FkFieldConfig<String>.password(
        validators: [Fk.required(), Fk.minLength(8)],
        label: 'Password',
      );

      expect(config.fieldType, FkFieldType.password);
    });

    test('creates a checkbox config with initial value', () {
      final config = FkFieldConfig<bool>.checkbox(
        initialValue: false,
        label: 'I agree',
        validators: [Fk.equals<bool>(true, message: 'Must accept')],
      );

      expect(config.fieldType, FkFieldType.checkbox);
      expect(config.initialValue, false);
    });

    test('creates a dropdown config with options', () {
      final config = FkFieldConfig<String>.dropdown(
        label: 'Country',
        options: ['US', 'UK', 'CA'],
        optionLabels: {
          'US': 'United States',
          'UK': 'United Kingdom',
          'CA': 'Canada',
        },
        validators: [Fk.required()],
      );

      expect(config.fieldType, FkFieldType.dropdown);
      expect(config.options, hasLength(3));
    });

    test('creates a date config', () {
      final config = FkFieldConfig<DateTime>.date(
        label: 'Birthday',
        validators: [Fk.required<DateTime>()],
      );

      expect(config.fieldType, FkFieldType.date);
    });

    test('buildController creates an FkFieldController with matching validators',
        () {
      final config = FkFieldConfig<String>.text(
        initialValue: 'hello',
        validators: [Fk.required()],
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
