import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('Bf.required()', () {
    final validator = Bf.required<String>();

    test('fails when value is null', () {
      expect(validator.validate(null), isNotNull);
      expect(validator.validate(null)!.code, 'required');
    });

    test('fails when value is empty string', () {
      expect(validator.validate(''), isNotNull);
      expect(validator.validate('  '), isNotNull);
    });

    test('passes for non-empty string', () {
      expect(validator.validate('hello'), isNull);
    });

    test('passes for non-null non-string types', () {
      final numValidator = Bf.required<int>();
      expect(numValidator.validate(0), isNull);
      expect(numValidator.validate(42), isNull);
    });

    test('supports custom message', () {
      final v = Bf.required<String>(message: 'Name is required');
      expect(v.validate(null)!.message, 'Name is required');
    });
  });

  group('Bf.email()', () {
    final validator = Bf.email();

    test('passes for valid email', () {
      expect(validator.validate('user@example.com'), isNull);
      expect(validator.validate('name+tag@domain.co.uk'), isNull);
    });

    test('fails for invalid email', () {
      expect(validator.validate('notanemail'), isNotNull);
      expect(validator.validate('missing@'), isNotNull);
      expect(validator.validate('@no-user.com'), isNotNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.minLength()', () {
    final validator = Bf.minLength(5);

    test('fails when string is shorter than min', () {
      final result = validator.validate('abc');
      expect(result, isNotNull);
      expect(result!.code, 'min_length');
    });

    test('passes at exact boundary', () {
      expect(validator.validate('abcde'), isNull);
    });

    test('passes when string is longer than min', () {
      expect(validator.validate('abcdef'), isNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.maxLength()', () {
    final validator = Bf.maxLength(5);

    test('fails when string is longer than max', () {
      final result = validator.validate('abcdef');
      expect(result, isNotNull);
      expect(result!.code, 'max_length');
    });

    test('passes at exact boundary', () {
      expect(validator.validate('abcde'), isNull);
    });

    test('passes when string is shorter than max', () {
      expect(validator.validate('abc'), isNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.pattern()', () {
    final validator = Bf.pattern(RegExp(r'^[A-Z]'));

    test('passes when string matches pattern', () {
      expect(validator.validate('Hello'), isNull);
    });

    test('fails when string does not match pattern', () {
      final result = validator.validate('hello');
      expect(result, isNotNull);
      expect(result!.code, 'pattern');
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.url()', () {
    final validator = Bf.url();

    test('passes for valid URLs', () {
      expect(validator.validate('https://example.com'), isNull);
      expect(validator.validate('http://example.com/path?q=1'), isNull);
      expect(validator.validate('ftp://files.example.com'), isNull);
    });

    test('fails for invalid URLs', () {
      expect(validator.validate('not-a-url'), isNotNull);
      expect(validator.validate('://missing-scheme.com'), isNotNull);
      expect(validator.validate('htp://typo.com'), isNotNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.phone()', () {
    final validator = Bf.phone();

    test('passes for valid phone numbers', () {
      expect(validator.validate('+1 234 567 8901'), isNull);
      expect(validator.validate('(123) 456-7890'), isNull);
      expect(validator.validate('1234567'), isNull);
    });

    test('fails for invalid phone numbers', () {
      expect(validator.validate('123'), isNotNull);
      expect(validator.validate('abc-defg'), isNotNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.creditCard()', () {
    final validator = Bf.creditCard();

    test('passes for valid Luhn number (Visa test card)', () {
      // 4111 1111 1111 1111 is a well-known test card number.
      expect(validator.validate('4111111111111111'), isNull);
      expect(validator.validate('4111 1111 1111 1111'), isNull);
    });

    test('fails for invalid card number', () {
      expect(validator.validate('1234567890123456'), isNotNull);
      expect(validator.validate('4111111111111112'), isNotNull);
    });

    test('fails for too-short number', () {
      expect(validator.validate('411111'), isNotNull);
    });

    test('skips null and empty', () {
      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });
  });

  group('Bf.min()', () {
    final validator = Bf.min(10);

    test('fails when value is below min', () {
      final result = validator.validate(5);
      expect(result, isNotNull);
      expect(result!.code, 'min');
    });

    test('passes at exact boundary', () {
      expect(validator.validate(10), isNull);
    });

    test('passes when value is above min', () {
      expect(validator.validate(15), isNull);
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.max()', () {
    final validator = Bf.max(100);

    test('fails when value exceeds max', () {
      final result = validator.validate(150);
      expect(result, isNotNull);
      expect(result!.code, 'max');
    });

    test('passes at exact boundary', () {
      expect(validator.validate(100), isNull);
    });

    test('passes when value is below max', () {
      expect(validator.validate(50), isNull);
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.between()', () {
    final validator = Bf.between(1, 10);

    test('fails when value is below range', () {
      expect(validator.validate(0), isNotNull);
    });

    test('fails when value is above range', () {
      expect(validator.validate(11), isNotNull);
    });

    test('passes at lower boundary', () {
      expect(validator.validate(1), isNull);
    });

    test('passes at upper boundary', () {
      expect(validator.validate(10), isNull);
    });

    test('passes within range', () {
      expect(validator.validate(5), isNull);
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.after()', () {
    final pivot = DateTime(2024, 6, 15);
    final validator = Bf.after(pivot);

    test('fails when date is before the target', () {
      expect(validator.validate(DateTime(2024, 6, 14)), isNotNull);
    });

    test('fails when date is equal to the target', () {
      expect(validator.validate(DateTime(2024, 6, 15)), isNotNull);
    });

    test('passes when date is after the target', () {
      expect(validator.validate(DateTime(2024, 6, 16)), isNull);
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.before()', () {
    final pivot = DateTime(2024, 6, 15);
    final validator = Bf.before(pivot);

    test('fails when date is after the target', () {
      expect(validator.validate(DateTime(2024, 6, 16)), isNotNull);
    });

    test('fails when date is equal to the target', () {
      expect(validator.validate(DateTime(2024, 6, 15)), isNotNull);
    });

    test('passes when date is before the target', () {
      expect(validator.validate(DateTime(2024, 6, 14)), isNull);
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.age()', () {
    test('fails when age is below minimum', () {
      final validator = Bf.age(18);
      // A date 10 years ago should fail for minimum 18.
      final tenYearsAgo = DateTime.now().subtract(const Duration(days: 3650));
      expect(validator.validate(tenYearsAgo), isNotNull);
    });

    test('passes when age meets minimum', () {
      final validator = Bf.age(18);
      // A date 20 years ago should pass for minimum 18.
      final twentyYearsAgo = DateTime(
        DateTime.now().year - 20,
        DateTime.now().month,
        DateTime.now().day,
      );
      expect(validator.validate(twentyYearsAgo), isNull);
    });

    test('skips null', () {
      expect(Bf.age(18).validate(null), isNull);
    });
  });

  group('Bf.equals()', () {
    final validator = Bf.equals<String>('yes');

    test('passes when value matches expected', () {
      expect(validator.validate('yes'), isNull);
    });

    test('fails when value does not match', () {
      final result = validator.validate('no');
      expect(result, isNotNull);
      expect(result!.code, 'equals');
    });

    test('skips null', () {
      expect(validator.validate(null), isNull);
    });
  });

  group('Bf.custom()', () {
    test('uses the callback to validate', () {
      final validator = Bf.custom<String>((value) {
        if (value != null && value.contains('bad')) {
          return const BfValidationResult('Contains bad word', code: 'custom');
        }
        return null;
      });

      expect(validator.validate('good'), isNull);
      expect(validator.validate('this is bad'), isNotNull);
    });
  });

  group('Bf.matchFields()', () {
    final validator = Bf.matchFields<String>('password');

    test('passes when values match', () {
      final context = BfValidationContext(
        fieldValueGetter: <T>(name) => 'secret123' as T,
      );
      expect(validator.validate('secret123', context), isNull);
    });

    test('fails when values do not match', () {
      final context = BfValidationContext(
        fieldValueGetter: <T>(name) => 'different' as T,
      );
      final result = validator.validate('secret123', context);
      expect(result, isNotNull);
      expect(result!.code, 'match_fields');
    });

    test('skips when context is null', () {
      expect(validator.validate('anything'), isNull);
    });

    test('skips when value is null', () {
      final context = BfValidationContext(
        fieldValueGetter: <T>(name) => 'something' as T,
      );
      expect(validator.validate(null, context), isNull);
    });
  });

  group('Bf.unique()', () {
    test('returns null (valid) when checker returns true', () async {
      final validator = Bf.unique<String>((value) async => true);
      final result = await validator.validate('available');
      expect(result, isNull);
    });

    test('returns error when checker returns false', () async {
      final validator = Bf.unique<String>((value) async => false);
      final result = await validator.validate('taken');
      expect(result, isNotNull);
      expect(result!.code, 'unique');
    });

    test('skips null value', () async {
      final validator = Bf.unique<String>((value) async => false);
      final result = await validator.validate(null);
      expect(result, isNull);
    });
  });
}
