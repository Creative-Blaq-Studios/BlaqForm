import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFormController', () {
    late BfFormController form;

    setUp(() {
      form = BfFormController();
    });

    tearDown(() {
      form.dispose();
    });

    group('register / unregister', () {
      test('registers a field and makes it accessible via field()', () {
        final email = BfFieldController<String>(initialValue: 'a@b.com');
        form.register('email', email);
        expect(form.field<String>('email'), same(email));
      });

      test('unregister removes the field', () {
        final email = BfFieldController<String>();
        form.register('email', email);
        form.unregister('email');

        expect(
          () => form.field<String>('email'),
          throwsA(isA<StateError>()),
        );
      });

      test('re-registering same name replaces previous controller', () {
        final first = BfFieldController<String>(initialValue: 'first');
        final second = BfFieldController<String>(initialValue: 'second');

        form.register('name', first);
        form.register('name', second);

        expect(form.field<String>('name'), same(second));
      });
    });

    test('field<T>() throws StateError for unknown name', () {
      expect(
        () => form.field<String>('unknown'),
        throwsA(isA<StateError>()),
      );
    });

    group('aggregate isValid', () {
      test('true when all fields are valid', () {
        final a = BfFieldController<String>(initialValue: 'hello');
        final b = BfFieldController<int>(initialValue: 42);
        form.register('a', a);
        form.register('b', b);
        expect(form.isValid, true);
      });

      test('false when any field has an error', () {
        final a = BfFieldController<String>(
          validators: [Bf.required<String>()],
        );
        form.register('a', a);
        // Set empty to trigger validation error.
        a.value = '';
        expect(form.isValid, false);
      });
    });

    group('aggregate isDirty', () {
      test('false when no fields are dirty', () {
        final a = BfFieldController<String>(initialValue: 'hello');
        form.register('a', a);
        expect(form.isDirty, false);
      });

      test('true when any field is dirty', () {
        final a = BfFieldController<String>(initialValue: 'hello');
        final b = BfFieldController<String>(initialValue: 'world');
        form.register('a', a);
        form.register('b', b);

        b.value = 'changed';
        expect(form.isDirty, true);
      });
    });

    test('errors map reflects field errors', () {
      final a = BfFieldController<String>(
        initialValue: 'ok',
        validators: [Bf.required<String>()],
      );
      final b = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );
      form.register('a', a);
      form.register('b', b);

      // Force sync validation on b.
      b.value = '';

      final errors = form.errors;
      expect(errors['a'], isNull);
      expect(errors['b'], isNotNull);
      expect(errors['b']!.code, 'required');
    });

    group('submit()', () {
      test('validates all fields and calls onSubmit when valid', () async {
        final email = BfFieldController<String>(
          initialValue: 'a@b.com',
          validators: [Bf.required<String>()],
        );
        form.register('email', email);

        Map<String, dynamic>? receivedValues;
        final result = await form.submit((values) async {
          receivedValues = values;
        });

        expect(result, true);
        expect(receivedValues, isNotNull);
        expect(receivedValues!['email'], 'a@b.com');
      });

      test('returns false when validation fails', () async {
        final email = BfFieldController<String>(
          validators: [Bf.required<String>()],
        );
        form.register('email', email);

        var onSubmitCalled = false;
        final result = await form.submit((values) async {
          onSubmitCalled = true;
        });

        expect(result, false);
        expect(onSubmitCalled, false);
      });

      test('sets isSubmitting during execution', () async {
        final email = BfFieldController<String>(
          initialValue: 'a@b.com',
          validators: [Bf.required<String>()],
        );
        form.register('email', email);

        bool? wasSubmittingDuringCallback;
        await form.submit((values) async {
          wasSubmittingDuringCallback = form.isSubmitting;
        });

        expect(wasSubmittingDuringCallback, true);
        expect(form.isSubmitting, false);
      });

      test('isSubmitting resets to false even if onSubmit throws', () async {
        final email = BfFieldController<String>(
          initialValue: 'ok',
          validators: [Bf.required<String>()],
        );
        form.register('email', email);

        try {
          await form.submit((values) async {
            throw Exception('Network error');
          });
        } catch (_) {
          // Expected.
        }

        expect(form.isSubmitting, false);
      });

      test('cross-field validators run on submit and can cause failure',
          () async {
        form = BfFormController(
          crossValidators: [
            Bf.custom<Map<String, dynamic>>((values) {
              if (values?['password'] != values?['confirm']) {
                return const BfValidationResult(
                  'Passwords must match',
                  code: 'cross',
                );
              }
              return null;
            }),
          ],
        );

        final password = BfFieldController<String>(
          initialValue: 'abc123',
          validators: [Bf.required<String>()],
        );
        final confirm = BfFieldController<String>(
          initialValue: 'different',
          validators: [Bf.required<String>()],
        );
        form.register('password', password);
        form.register('confirm', confirm);

        var onSubmitCalled = false;
        final result = await form.submit((values) async {
          onSubmitCalled = true;
        });

        expect(result, false);
        expect(onSubmitCalled, false);
        expect(form.isValid, false);
      });
    });

    test('reset() resets all fields', () {
      final a = BfFieldController<String>(
        initialValue: 'init',
        validators: [Bf.required<String>()],
      );
      form.register('a', a);

      a.value = 'changed';
      a.markTouched();
      expect(a.isDirty, true);
      expect(a.isTouched, true);

      form.reset();
      expect(a.value, 'init');
      expect(a.isDirty, false);
      expect(a.isTouched, false);
    });

    test('toMap() returns all field values', () {
      final name = BfFieldController<String>(initialValue: 'Alice');
      final age = BfFieldController<int>(initialValue: 30);
      form.register('name', name);
      form.register('age', age);

      final map = form.toMap();
      expect(map, {'name': 'Alice', 'age': 30});
    });
  });
}
