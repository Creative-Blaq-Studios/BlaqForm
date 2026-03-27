import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('Cross-field validation (matchFields)', () {
    test('submit with mismatched values fails', () async {
      // Given: a form with password and confirmPassword fields
      // where confirmPassword uses Fk.matchFields('password')
      final form = FkFormController();
      final passwordCtrl = FkFieldController<String>(
        initialValue: 'secret123',
        validators: [Fk.required<String>()],
      );
      final confirmCtrl = FkFieldController<String>(
        initialValue: 'different',
        validators: [
          Fk.required<String>(),
          Fk.matchFields<String>('password', message: 'Passwords must match'),
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
      final form = FkFormController();
      final passwordCtrl = FkFieldController<String>(
        initialValue: 'secret123',
        validators: [Fk.required<String>()],
      );
      final confirmCtrl = FkFieldController<String>(
        initialValue: 'secret123',
        validators: [
          Fk.required<String>(),
          Fk.matchFields<String>('password', message: 'Passwords must match'),
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
