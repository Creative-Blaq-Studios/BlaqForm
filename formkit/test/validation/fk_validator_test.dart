import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkValidator composition operators', () {
    // Two simple validators for composition tests.
    final alwaysFail = Fk.custom<String>(
      (_) => const FkValidationResult('first error', code: 'first'),
    );
    final alwaysFailSecond = Fk.custom<String>(
      (_) => const FkValidationResult('second error', code: 'second'),
    );
    final alwaysPass = Fk.custom<String>((_) => null);

    group('.and()', () {
      test('fails with first error if the first validator fails (short-circuit)',
          () {
        final validator = alwaysFail.and(alwaysPass);
        final result = validator.validate('test');
        expect(result, isNotNull);
        expect(result!.code, 'first');
      });

      test('fails with second error if first passes but second fails', () {
        final validator = alwaysPass.and(alwaysFailSecond);
        final result = validator.validate('test');
        expect(result, isNotNull);
        expect(result!.code, 'second');
      });

      test('passes if both validators pass', () {
        final validator = alwaysPass.and(alwaysPass);
        final result = validator.validate('test');
        expect(result, isNull);
      });
    });

    group('.or()', () {
      test('passes if the first validator passes', () {
        final validator = alwaysPass.or(alwaysFail);
        final result = validator.validate('test');
        expect(result, isNull);
      });

      test('passes if the second validator passes', () {
        final validator = alwaysFail.or(alwaysPass);
        final result = validator.validate('test');
        expect(result, isNull);
      });

      test('fails with second error if both validators fail', () {
        final validator = alwaysFail.or(alwaysFailSecond);
        final result = validator.validate('test');
        expect(result, isNotNull);
        expect(result!.code, 'second');
      });
    });

    group('.when()', () {
      test('skips validation when predicate is false', () {
        final validator = alwaysFail.when((_) => false);
        final result = validator.validate('test');
        expect(result, isNull);
      });

      test('runs validation when predicate is true', () {
        final validator = alwaysFail.when((_) => true);
        final result = validator.validate('test');
        expect(result, isNotNull);
        expect(result!.code, 'first');
      });

      test('predicate receives FkValidationContext when provided', () {
        // The predicate should receive the context so it can check
        // sibling field values for conditional validation.
        FkValidationContext? receivedContext;
        final validator = Fk.required<String>().when((context) {
          receivedContext = context;
          return true;
        });

        final context = FkValidationContext(
          fieldValueGetter: <T>(name) => 'test' as T,
        );

        validator.validate(null, context);
        expect(receivedContext, isNotNull);
        expect(receivedContext, same(context));
      });

      test('predicate can use context to conditionally skip validation', () {
        // Only require this field when sibling "type" == "business"
        final validator = Fk.required<String>().when((context) {
          final type = context?.sibling<String>('type');
          return type == 'business';
        });

        final personalContext = FkValidationContext(
          fieldValueGetter: <T>(name) => 'personal' as T,
        );
        final businessContext = FkValidationContext(
          fieldValueGetter: <T>(name) => 'business' as T,
        );

        // Should skip validation for "personal" (predicate returns false)
        expect(validator.validate(null, personalContext), isNull);

        // Should run validation for "business" (predicate returns true, value is null)
        expect(validator.validate(null, businessContext), isNotNull);
      });

      test('predicate works without context (receives null)', () {
        // When no context is provided, predicate gets null
        final validator = Fk.required<String>().when((context) {
          return context == null; // skip when no context
        });

        // No context → predicate receives null → returns true → validates
        expect(validator.validate(null), isNotNull);
      });
    });
  });
}
