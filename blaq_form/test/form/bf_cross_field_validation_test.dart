import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('Cross-field validation (matchFields)', () {
    test('submit with mismatched values fails', () async {
      // Given: a form with password and confirmPassword fields
      // where confirmPassword uses Bf.matchFields('password')
      final form = BfFormController();
      final passwordCtrl = BfFieldController<String>(
        initialValue: 'secret123',
        validators: [Bf.required<String>()],
      );
      final confirmCtrl = BfFieldController<String>(
        initialValue: 'different',
        validators: [
          Bf.required<String>(),
          Bf.matchFields<String>('password', message: 'Passwords must match'),
        ],
      );
      form.register('password', passwordCtrl);
      form.register('confirmPassword', confirmCtrl);

      // When: the form is submitted with mismatched values
      var submitCalled = false;
      final result = await form.submit((values) async {
        submitCalled = true;
      });

      // Then: submission fails and the callback was not called
      expect(result, isFalse);
      expect(submitCalled, isFalse);
      expect(confirmCtrl.error, isNotNull);
      expect(confirmCtrl.error!.message, equals('Passwords must match'));

      form.dispose();
      passwordCtrl.dispose();
      confirmCtrl.dispose();
    });

    test('submit with matched values succeeds', () async {
      // Given: a form with matching password and confirmPassword fields
      final form = BfFormController();
      final passwordCtrl = BfFieldController<String>(
        initialValue: 'secret123',
        validators: [Bf.required<String>()],
      );
      final confirmCtrl = BfFieldController<String>(
        initialValue: 'secret123',
        validators: [
          Bf.required<String>(),
          Bf.matchFields<String>('password', message: 'Passwords must match'),
        ],
      );
      form.register('password', passwordCtrl);
      form.register('confirmPassword', confirmCtrl);

      // When: the form is submitted with matching values
      var submitCalled = false;
      final result = await form.submit((values) async {
        submitCalled = true;
      });

      // Then: submission succeeds and the callback was called
      expect(result, isTrue);
      expect(submitCalled, isTrue);
      expect(confirmCtrl.error, isNull);

      form.dispose();
      passwordCtrl.dispose();
      confirmCtrl.dispose();
    });
  });
}
