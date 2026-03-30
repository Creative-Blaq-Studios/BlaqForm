import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfValidationResult', () {
    test('stores message', () {
      final result = BfValidationResult('Required');
      expect(result.message, 'Required');
    });

    test('stores code', () {
      final result = BfValidationResult('Too short', code: 'min_length');
      expect(result.code, 'min_length');
    });

    test('stores params', () {
      final result = BfValidationResult(
        'Must be at least 8',
        code: 'min_length',
        params: {'min': 8, 'actual': 3},
      );
      expect(result.params['min'], 8);
      expect(result.params['actual'], 3);
    });

    test('defaults to empty params', () {
      final result = BfValidationResult('Error');
      expect(result.params, isEmpty);
    });

    test('code defaults to null', () {
      final result = BfValidationResult('Error');
      expect(result.code, isNull);
    });

    test('toString includes message', () {
      final result = BfValidationResult('Field required');
      expect(result.toString(), contains('Field required'));
    });

    test('toString includes code when provided', () {
      final result = BfValidationResult('Too short', code: 'min_length');
      expect(result.toString(), contains('min_length'));
    });

    test('equality — same message and code are equal', () {
      const a = BfValidationResult('Error', code: 'err');
      const b = BfValidationResult('Error', code: 'err');
      expect(a, equals(b));
    });

    test('equality — different message are not equal', () {
      const a = BfValidationResult('Error A');
      const b = BfValidationResult('Error B');
      expect(a, isNot(equals(b)));
    });

    test('equality — different code are not equal', () {
      const a = BfValidationResult('Error', code: 'code_a');
      const b = BfValidationResult('Error', code: 'code_b');
      expect(a, isNot(equals(b)));
    });

    test('hashCode — equal objects have same hashCode', () {
      const a = BfValidationResult('Error', code: 'err');
      const b = BfValidationResult('Error', code: 'err');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('can be constructed as const', () {
      const result = BfValidationResult('Constant error', code: 'c');
      expect(result.message, 'Constant error');
    });
  });
}
