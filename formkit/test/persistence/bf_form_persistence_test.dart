import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfMemoryPersistence', () {
    late BfMemoryPersistence persistence;

    setUp(() {
      persistence = BfMemoryPersistence();
    });

    test('save stores values — load returns them', () async {
      const values = {'name': 'Alice', 'age': 30};
      await persistence.save(values);
      final loaded = await persistence.load();
      expect(loaded, equals(values));
    });

    test('load returns null when nothing saved', () async {
      final loaded = await persistence.load();
      expect(loaded, isNull);
    });

    test('clear removes saved values', () async {
      await persistence.save({'email': 'test@example.com'});
      await persistence.clear();
      final loaded = await persistence.load();
      expect(loaded, isNull);
    });

    test('save overwrites previous values', () async {
      await persistence.save({'step': 1});
      await persistence.save({'step': 2, 'name': 'Bob'});
      final loaded = await persistence.load();
      expect(loaded, equals({'step': 2, 'name': 'Bob'}));
      expect(loaded!.containsKey('name'), isTrue);
    });
  });

  group('BfFormPersistence integration', () {
    late BfMemoryPersistence persistence;
    late BfFormController form;
    late BfFieldController<String> nameField;
    late BfFieldController<String> emailField;

    setUp(() {
      persistence = BfMemoryPersistence();
      form = BfFormController();
      nameField = BfFieldController<String>(initialValue: '');
      emailField = BfFieldController<String>(initialValue: '');
      form.register('name', nameField);
      form.register('email', emailField);
    });

    tearDown(() {
      form.dispose();
    });

    test('saveForm serializes controller values', () async {
      nameField.value = 'Alice';
      emailField.value = 'alice@example.com';

      await persistence.saveForm(form);
      final loaded = await persistence.load();

      expect(loaded, isNotNull);
      expect(loaded!['name'], equals('Alice'));
      expect(loaded['email'], equals('alice@example.com'));
    });

    test('restoreForm populates registered fields', () async {
      await persistence.save({
        'name': 'Bob',
        'email': 'bob@example.com',
        'unregistered': 'ignored',
      });

      await persistence.restoreForm(form);

      expect(nameField.value, equals('Bob'));
      expect(emailField.value, equals('bob@example.com'));
    });
  });
}
