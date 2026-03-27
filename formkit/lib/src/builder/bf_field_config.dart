import 'package:flutter/widgets.dart';

import '../state/bf_field_controller.dart';
import '../validation/bf_async_validator.dart';
import '../validation/bf_validator.dart';

/// Enumerates the supported field types for [BfFieldConfig].
///
/// Used by form builders to determine which widget to render for a given
/// field configuration.
enum BfFieldType {
  /// A standard single-line text input.
  text,

  /// A password input with obscured text.
  password,

  /// An email input (text field with email keyboard hints).
  email,

  /// A boolean checkbox toggle.
  checkbox,

  /// A boolean switch toggle.
  switchToggle,

  /// A dropdown selector for picking from a list of options.
  dropdown,

  /// A date picker field.
  date,

  /// A date range picker field.
  dateRange,

  /// A slider for numeric range selection.
  slider,

  /// A rating field (e.g., star rating).
  rating,

  /// A custom field type rendered via [BfFieldConfig.widgetBuilder].
  custom,
}

/// A declarative, immutable description of a form field.
///
/// [BfFieldConfig] holds all the metadata needed to create an
/// [BfFieldController] and render the appropriate widget, without
/// actually creating either. This makes it ideal for schema-driven
/// form generation.
///
/// ```dart
/// final emailConfig = BfFieldConfig<String>.text(
///   validators: [Bf.required(), Bf.email()],
///   label: 'Email',
///   hint: 'you@example.com',
/// );
///
/// // Later, create a controller from the config:
/// final controller = emailConfig.buildController();
/// ```
class BfFieldConfig<T> {
  /// The type of field this config represents.
  final BfFieldType fieldType;

  /// The initial value for the field, or `null` if none.
  final T? initialValue;

  /// Synchronous validators to run on value changes.
  final List<BfValidator<T>> validators;

  /// Asynchronous validators to run after sync validators pass.
  final List<BfAsyncValidator<T>> asyncValidators;

  /// Debounce duration for async validators.
  final Duration asyncDebounce;

  /// A human-readable label for the field.
  final String? label;

  /// Placeholder / hint text shown when the field is empty.
  final String? hint;

  /// An optional icon displayed before the field content.
  final IconData? prefixIcon;

  /// An optional icon displayed after the field content.
  final IconData? suffixIcon;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// Available options for [BfFieldType.dropdown] fields.
  final List<T>? options;

  /// Display labels for dropdown options, keyed by option value.
  final Map<T, String>? optionLabels;

  /// An optional custom widget builder for [BfFieldType.custom] fields.
  final Widget Function(BfFieldController<T> controller)? widgetBuilder;

  /// Creates an [BfFieldConfig] with full control over all parameters.
  const BfFieldConfig({
    required this.fieldType,
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.options,
    this.optionLabels,
    this.widgetBuilder,
  });

  /// Creates a text field configuration.
  ///
  /// ```dart
  /// BfFieldConfig<String>.text(
  ///   validators: [Bf.required(), Bf.email()],
  ///   label: 'Email',
  /// );
  /// ```
  const BfFieldConfig.text({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = BfFieldType.text,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates a password field configuration.
  ///
  /// ```dart
  /// BfFieldConfig<String>.password(
  ///   validators: [Bf.required(), Bf.minLength(8)],
  ///   label: 'Password',
  /// );
  /// ```
  const BfFieldConfig.password({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = BfFieldType.password,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates an email field configuration.
  ///
  /// ```dart
  /// BfFieldConfig<String>.email(
  ///   validators: [Bf.required(), Bf.email()],
  ///   label: 'Email Address',
  /// );
  /// ```
  const BfFieldConfig.email({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = BfFieldType.email,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates a checkbox field configuration.
  ///
  /// ```dart
  /// BfFieldConfig<bool>.checkbox(
  ///   initialValue: false,
  ///   label: 'I agree to the terms',
  ///   validators: [Bf.equals<bool>(true, message: 'Must accept')],
  /// );
  /// ```
  const BfFieldConfig.checkbox({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.enabled = true,
  })  : fieldType = BfFieldType.checkbox,
        prefixIcon = null,
        suffixIcon = null,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates a dropdown field configuration.
  ///
  /// [options] provides the list of selectable values. Use [optionLabels]
  /// to map values to human-readable display strings.
  ///
  /// ```dart
  /// BfFieldConfig<String>.dropdown(
  ///   label: 'Country',
  ///   options: ['US', 'UK', 'CA'],
  ///   optionLabels: {'US': 'United States', 'UK': 'United Kingdom', 'CA': 'Canada'},
  ///   validators: [Bf.required()],
  /// );
  /// ```
  const BfFieldConfig.dropdown({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.options,
    this.optionLabels,
  })  : fieldType = BfFieldType.dropdown,
        widgetBuilder = null;

  /// Creates a date picker field configuration.
  ///
  /// ```dart
  /// BfFieldConfig<DateTime>.date(
  ///   label: 'Birthday',
  ///   validators: [Bf.required<DateTime>()],
  /// );
  /// ```
  const BfFieldConfig.date({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = BfFieldType.date,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates an [BfFieldController] from this configuration.
  ///
  /// The returned controller is initialized with the [initialValue],
  /// [validators], [asyncValidators], and [asyncDebounce] defined in
  /// this config.
  ///
  /// ```dart
  /// final config = BfFieldConfig<String>.text(
  ///   initialValue: 'hello',
  ///   validators: [Bf.required()],
  /// );
  /// final controller = config.buildController();
  /// ```
  BfFieldController<T> buildController() {
    return BfFieldController<T>(
      initialValue: initialValue,
      validators: validators,
      asyncValidators: asyncValidators,
      asyncDebounce: asyncDebounce,
      debugLabel: label,
    );
  }
}
