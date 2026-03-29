import 'package:flutter/material.dart';
import 'package:blaq_form/blaq_form.dart';

/// Wraps [child] in a MaterialApp + Scaffold + BfForm for widget testing.
Widget buildTestForm({
  required Widget child,
  BfFormController? controller,
  BfAutovalidateMode autovalidateMode = BfAutovalidateMode.always,
}) {
  return MaterialApp(
    home: Scaffold(
      body: BfForm(
        controller: controller ?? BfFormController(),
        autovalidateMode: autovalidateMode,
        child: child,
      ),
    ),
  );
}

/// A simple always-failing validator for testing purposes.
class AlwaysInvalidValidator extends BfValidator<String> {
  final String errorMessage;

  const AlwaysInvalidValidator([this.errorMessage = 'This field is invalid']);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    return BfValidationResult(errorMessage);
  }
}

/// A simple always-failing validator for bool fields.
class AlwaysInvalidBoolValidator extends BfValidator<bool> {
  final String errorMessage;

  const AlwaysInvalidBoolValidator(
      [this.errorMessage = 'This field is invalid']);

  @override
  BfValidationResult? validate(bool? value, [BfValidationContext? context]) {
    return BfValidationResult(errorMessage);
  }
}

/// A validator that fails when the bool value is false or null.
class RequiredBoolValidator extends BfValidator<bool> {
  const RequiredBoolValidator();

  @override
  BfValidationResult? validate(bool? value, [BfValidationContext? context]) {
    if (value != true) {
      return const BfValidationResult('This field is required');
    }
    return null;
  }
}
