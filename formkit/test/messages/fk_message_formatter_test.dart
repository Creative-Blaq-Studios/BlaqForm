import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkMessageFormatter', () {
    group('format()', () {
      test('replaces {field} token with fieldName', () {
        const template = '{field} is required';
        final result = FkMessageFormatter.format(
          template,
          fieldName: 'Email',
        );
        expect(result, 'Email is required');
      });

      test('replaces params tokens in template', () {
        const template =
            'Password must be at least {min} characters (got {actual})';
        final result = FkMessageFormatter.format(
          template,
          params: {'min': 8, 'actual': 3},
        );
        expect(result, 'Password must be at least 8 characters (got 3)');
      });

      test('leaves unknown tokens as-is', () {
        const template = '{unknown}';
        final result = FkMessageFormatter.format(template);
        expect(result, '{unknown}');
      });

      test('leaves {field} token as-is when fieldName is null', () {
        const template = '{field} is required';
        final result = FkMessageFormatter.format(template);
        expect(result, '{field} is required');
      });

      test('leaves {min} token as-is when params is empty', () {
        const template = 'Must be at least {min} characters';
        final result = FkMessageFormatter.format(
          template,
          params: const {},
        );
        expect(result, 'Must be at least {min} characters');
      });
    });

    group('formatResult()', () {
      test('formats FkValidationResult message using its params and fieldName',
          () {
        final result = const FkValidationResult(
          '{field} must be at least {min} characters',
          code: 'min_length',
          params: {'min': 8},
        );
        final formatted = FkMessageFormatter.formatResult(
          result,
          fieldName: 'Password',
        );
        expect(formatted, 'Password must be at least 8 characters');
      });
    });
  });
}
