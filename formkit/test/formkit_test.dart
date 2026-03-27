import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

/// Smoke test verifying the barrel export can be imported without errors.
void main() {
  test('formkit barrel export can be imported', () {
    // Verify key types are accessible through the barrel import.
    expect(Fk, isNotNull);
    expect(FkFieldController<String>.new, isA<Function>());
    expect(FkFormController.new, isA<Function>());
  });
}
