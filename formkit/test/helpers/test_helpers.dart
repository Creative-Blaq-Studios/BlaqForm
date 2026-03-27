import 'package:flutter/material.dart';
import 'package:formkit/formkit.dart';

/// Wraps [child] in a MaterialApp + Scaffold + FkForm for widget testing.
Widget buildTestForm({
  required Widget child,
  FkFormController? controller,
  FkAutovalidateMode autovalidateMode = FkAutovalidateMode.always,
}) {
  return MaterialApp(
    home: Scaffold(
      body: FkForm(
        controller: controller ?? FkFormController(),
        autovalidateMode: autovalidateMode,
        child: child,
      ),
    ),
  );
}

/// A simple always-failing validator for testing purposes.
class AlwaysInvalidValidator extends FkValidator<String> {
  final String errorMessage;

  const AlwaysInvalidValidator([this.errorMessage = 'This field is invalid']);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    return FkValidationResult(errorMessage);
  }
}

/// A simple always-failing validator for bool fields.
class AlwaysInvalidBoolValidator extends FkValidator<bool> {
  final String errorMessage;

  const AlwaysInvalidBoolValidator(
      [this.errorMessage = 'This field is invalid']);

  @override
  FkValidationResult? validate(bool? value, [FkValidationContext? context]) {
    return FkValidationResult(errorMessage);
  }
}

/// A validator that fails when the bool value is false or null.
class RequiredBoolValidator extends FkValidator<bool> {
  const RequiredBoolValidator();

  @override
  FkValidationResult? validate(bool? value, [FkValidationContext? context]) {
    if (value != true) {
      return const FkValidationResult('This field is required');
    }
    return null;
  }
}
