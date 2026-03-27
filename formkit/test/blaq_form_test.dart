import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

/// Smoke test verifying the barrel export can be imported without errors.
void main() {
  test('formkit barrel export can be imported', () {
    // Verify key types are accessible through the barrel import.
    expect(Bf, isNotNull);
    expect(BfFieldController<String>.new, isA<Function>());
    expect(BfFormController.new, isA<Function>());
  });
}
