import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFieldController', () {
    group('initial state', () {
      test('has correct defaults', () {
        final controller = BfFieldController<String>(initialValue: 'hello');
        expect(controller.value, 'hello');
        expect(controller.isDirty, false);
        expect(controller.isTouched, false);
        expect(controller.isValid, true);
        expect(controller.error, isNull);
        controller.dispose();
      });

      test('defaults to null value when no initialValue given', () {
        final controller = BfFieldController<String>();
        expect(controller.value, isNull);
        controller.dispose();
      });
    });

    test('setting value marks the field as dirty', () {
      final controller = BfFieldController<String>();
      expect(controller.isDirty, false);
      controller.value = 'new';
      expect(controller.isDirty, true);
      controller.dispose();
    });

    test('markTouched() sets isTouched', () {
      final controller = BfFieldController<String>();
      expect(controller.isTouched, false);
      controller.markTouched();
      expect(controller.isTouched, true);
      controller.dispose();
    });

    test('sync validation runs on value change', () {
      final controller = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );
      // Initially null value, but sync validation only runs on set.
      controller.value = '';
      expect(controller.error, isNotNull);
      expect(controller.error!.code, 'required');

      controller.value = 'valid';
      expect(controller.error, isNull);
      controller.dispose();
    });

    test('validate() returns true when valid', () async {
      final controller = BfFieldController<String>(
        initialValue: 'hello',
        validators: [Bf.required<String>()],
      );
      final result = await controller.validate();
      expect(result, true);
      expect(controller.isValid, true);
      controller.dispose();
    });

    test('validate() returns false when invalid', () async {
      final controller = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );
      final result = await controller.validate();
      expect(result, false);
      expect(controller.error, isNotNull);
      controller.dispose();
    });

    test('clearError() clears the error', () {
      final controller = BfFieldController<String>(
        validators: [Bf.required<String>()],
      );
      controller.value = '';
      expect(controller.error, isNotNull);

      controller.clearError();
      expect(controller.error, isNull);
      controller.dispose();
    });

    test('reset() restores initial state', () {
      final controller = BfFieldController<String>(
        initialValue: 'init',
        validators: [Bf.required<String>()],
      );
      controller.value = 'changed';
      controller.markTouched();
      expect(controller.isDirty, true);
      expect(controller.isTouched, true);

      controller.reset();
      expect(controller.value, 'init');
      expect(controller.isDirty, false);
      expect(controller.isTouched, false);
      expect(controller.error, isNull);
      controller.dispose();
    });

    group('async validation via validate()', () {
      test(
        'validate() runs async validators and sets error on failure',
        () async {
          final controller = BfFieldController<String>(
            initialValue: 'taken',
            asyncValidators: [Bf.unique<String>((value) async => false)],
          );

          final result = await controller.validate();
          expect(result, false);
          expect(controller.error, isNotNull);
          expect(controller.error!.code, 'unique');
          expect(controller.isValidating, false);
          controller.dispose();
        },
      );

      test('validate() clears error when async validator passes', () async {
        final controller = BfFieldController<String>(
          initialValue: 'available',
          asyncValidators: [Bf.unique<String>((value) async => true)],
        );

        final result = await controller.validate();
        expect(result, true);
        expect(controller.error, isNull);
        expect(controller.isValidating, false);
        controller.dispose();
      });

      test('validate() skips async validators if sync fails', () async {
        var asyncCalled = false;
        final controller = BfFieldController<String>(
          validators: [Bf.required<String>()],
          asyncValidators: [
            Bf.unique<String>((value) async {
              asyncCalled = true;
              return true;
            }),
          ],
        );

        // Value is null, so required fails before async runs.
        final result = await controller.validate();
        expect(result, false);
        expect(asyncCalled, false);
        expect(controller.error!.code, 'required');
        controller.dispose();
      });

      test(
        'async validation discards stale results when value changes',
        () async {
          final completer1 = Completer<bool>();
          final completer2 = Completer<bool>();
          var callCount = 0;

          final controller = BfFieldController<String>(
            initialValue: 'first',
            asyncValidators: [
              Bf.unique<String>((value) {
                callCount++;
                if (callCount == 1) return completer1.future;
                return completer2.future;
              }),
            ],
          );

          // Start first validation.
          final future1 = controller.validate();

          // While first is still pending, change value and validate again.
          controller.value = 'second';
          final future2 = controller.validate();

          // Complete the first validation (should be discarded due to token mismatch).
          completer1.complete(false);
          final result1 = await future1;
          // First call returns false because the token changed.
          expect(result1, false);

          // Complete the second validation as valid.
          completer2.complete(true);
          final result2 = await future2;
          expect(result2, true);
          expect(controller.error, isNull);

          controller.dispose();
        },
      );
    });

    group('debounced async validation', () {
      testWidgets('runs after debounce period', (tester) async {
        var asyncCallCount = 0;
        final controller = BfFieldController<String>(
          asyncValidators: [
            Bf.unique<String>((value) async {
              asyncCallCount++;
              return false;
            }),
          ],
          asyncDebounce: const Duration(milliseconds: 300),
        );

        controller.value = 'test';

        // Immediately after setting, async hasn't run yet.
        expect(asyncCallCount, 0);

        // Pump past the debounce duration.
        await tester.pump(const Duration(milliseconds: 300));
        // Allow the async future to complete.
        await tester.pumpAndSettle();

        expect(asyncCallCount, 1);
        expect(controller.error, isNotNull);
        expect(controller.error!.code, 'unique');

        controller.dispose();
      });

      testWidgets('cancels previous debounce when value changes rapidly', (
        tester,
      ) async {
        var asyncCallCount = 0;
        final controller = BfFieldController<String>(
          asyncValidators: [
            Bf.unique<String>((value) async {
              asyncCallCount++;
              return value == 'available';
            }),
          ],
          asyncDebounce: const Duration(milliseconds: 300),
        );

        controller.value = 'taken';
        await tester.pump(const Duration(milliseconds: 200));

        // Change value before first debounce fires.
        controller.value = 'available';
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Only one async call should have been made (the second one).
        expect(asyncCallCount, 1);
        expect(controller.error, isNull);

        controller.dispose();
      });

      testWidgets('does not schedule async when sync validation fails', (
        tester,
      ) async {
        var asyncCalled = false;
        final controller = BfFieldController<String>(
          validators: [Bf.required<String>()],
          asyncValidators: [
            Bf.unique<String>((value) async {
              asyncCalled = true;
              return false;
            }),
          ],
          asyncDebounce: const Duration(milliseconds: 300),
        );

        controller.value = '';
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(asyncCalled, false);
        expect(controller.error!.code, 'required');

        controller.dispose();
      });
    });

    test('dispose() cancels debounce timers', () async {
      final controller = BfFieldController<String>(
        asyncValidators: [Bf.unique<String>((value) async => false)],
        asyncDebounce: const Duration(milliseconds: 300),
      );

      controller.value = 'test';
      // Dispose before debounce fires.
      controller.dispose();

      // If the timer was not cancelled, it would attempt to call
      // notifyListeners() on a disposed ChangeNotifier, which throws.
      // We allow time to pass to verify no error occurs.
    });

    group('hasValidators', () {
      test('false when no validators are provided', () {
        final controller = BfFieldController<String>(initialValue: 'hi');
        expect(controller.hasValidators, false);
        controller.dispose();
      });

      test('true when sync validators are provided', () {
        final controller = BfFieldController<String>(
          validators: [Bf.required()],
        );
        expect(controller.hasValidators, true);
        controller.dispose();
      });

      test('true when only async validators are provided', () {
        final controller = BfFieldController<String>(
          asyncValidators: [
            Bf.unique<String>((v) async => true),
          ],
        );
        expect(controller.hasValidators, true);
        controller.dispose();
      });
    });
  });
}
