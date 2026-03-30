import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFormControllerJsonX', () {
    test('toJson() returns field values as JSON map', () {
      // Given: a form with registered fields
      final form = BfFormController();
      final nameCtrl = BfFieldController<String>(initialValue: 'Alice');
      final ageCtrl = BfFieldController<int>(initialValue: 30);
      form.register('name', nameCtrl);
      form.register('age', ageCtrl);

      // When: we call toJson()
      final json = form.toJson();

      // Then: it returns the field values as a map
      expect(json, equals({'name': 'Alice', 'age': 30}));

      form.dispose();
      nameCtrl.dispose();
      ageCtrl.dispose();
    });

    test('toJson() converts DateTime to ISO 8601 string', () {
      // Given: a form with a DateTime field
      final form = BfFormController();
      final dateCtrl = BfFieldController<DateTime>(
        initialValue: DateTime(2025, 6, 15),
      );
      form.register('dob', dateCtrl);

      // When: we call toJson()
      final json = form.toJson();

      // Then: the DateTime is serialized as ISO 8601
      expect(json['dob'], equals(DateTime(2025, 6, 15).toIso8601String()));

      form.dispose();
      dateCtrl.dispose();
    });

    test('toJson() passes through null, num, bool, String', () {
      // Given: a form with various primitive field types
      final form = BfFormController();
      final nullCtrl = BfFieldController<String>();
      final numCtrl = BfFieldController<double>(initialValue: 3.14);
      final boolCtrl = BfFieldController<bool>(initialValue: true);
      final strCtrl = BfFieldController<String>(initialValue: 'text');
      form.register('nullField', nullCtrl);
      form.register('numField', numCtrl);
      form.register('boolField', boolCtrl);
      form.register('strField', strCtrl);

      // When: we call toJson()
      final json = form.toJson();

      // Then: primitive values are passed through as-is
      expect(json['nullField'], isNull);
      expect(json['numField'], equals(3.14));
      expect(json['boolField'], equals(true));
      expect(json['strField'], equals('text'));

      form.dispose();
      nullCtrl.dispose();
      numCtrl.dispose();
      boolCtrl.dispose();
      strCtrl.dispose();
    });

    test('toJson() converts unknown types to String via toString()', () {
      // Given: a form with a field holding a custom object type
      final form = BfFormController();
      final ctrl = BfFieldController<_CustomObject>(
        initialValue: _CustomObject('hello'),
      );
      form.register('custom', ctrl);

      // When: we call toJson()
      final json = form.toJson();

      // Then: the unknown type is converted to string
      expect(json['custom'], equals('_CustomObject(hello)'));

      form.dispose();
      ctrl.dispose();
    });

    test('fromJson() populates registered fields', () {
      // Given: a form with registered fields
      final form = BfFormController();
      final nameCtrl = BfFieldController<String>();
      final ageCtrl = BfFieldController<dynamic>();
      form.register('name', nameCtrl);
      form.register('age', ageCtrl);

      // When: we call fromJson()
      form.fromJson({'name': 'Bob', 'age': 25});

      // Then: registered fields are populated
      expect(nameCtrl.value, equals('Bob'));
      expect(ageCtrl.value, equals(25));

      form.dispose();
      nameCtrl.dispose();
      ageCtrl.dispose();
    });

    test('fromJson() skips unregistered field names', () {
      // Given: a form with one registered field
      final form = BfFormController();
      final nameCtrl = BfFieldController<String>(initialValue: 'original');
      form.register('name', nameCtrl);

      // When: we call fromJson() with an extra unregistered field
      form.fromJson({'name': 'updated', 'unknown': 'value'});

      // Then: the registered field is updated and no error is thrown
      expect(nameCtrl.value, equals('updated'));

      form.dispose();
      nameCtrl.dispose();
    });
  });

  group('BfFormControllerDiffX', () {
    test('dirtyValues() returns only dirty fields', () {
      // Given: a form with two fields, one of which is modified
      final form = BfFormController();
      final nameCtrl = BfFieldController<String>(initialValue: 'Alice');
      final emailCtrl = BfFieldController<String>(initialValue: 'a@b.com');
      form.register('name', nameCtrl);
      form.register('email', emailCtrl);

      // When: one field is changed (becomes dirty)
      nameCtrl.value = 'Bob';

      // Then: dirtyValues returns only the dirty field
      final dirty = form.dirtyValues();
      expect(dirty, equals({'name': 'Bob'}));
      expect(dirty.containsKey('email'), isFalse);

      form.dispose();
      nameCtrl.dispose();
      emailCtrl.dispose();
    });

    test('dirtyValues() returns empty map when nothing is dirty', () {
      // Given: a form with fields that have not been modified
      final form = BfFormController();
      final nameCtrl = BfFieldController<String>(initialValue: 'Alice');
      form.register('name', nameCtrl);

      // When: no changes have been made
      final dirty = form.dirtyValues();

      // Then: an empty map is returned
      expect(dirty, isEmpty);

      form.dispose();
      nameCtrl.dispose();
    });
  });
}

/// A custom object type used to test toString() fallback in toJson().
class _CustomObject {
  final String data;
  const _CustomObject(this.data);

  @override
  String toString() => '_CustomObject($data)';
}
