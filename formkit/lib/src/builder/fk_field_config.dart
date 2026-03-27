import 'package:flutter/widgets.dart';

import '../state/fk_field_controller.dart';
import '../validation/fk_async_validator.dart';
import '../validation/fk_validator.dart';

/// Enumerates the supported field types for [FkFieldConfig].
///
/// Used by form builders to determine which widget to render for a given
/// field configuration.
enum FkFieldType {
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

  /// A custom field type rendered via [FkFieldConfig.widgetBuilder].
  custom,
}

/// A declarative, immutable description of a form field.
///
/// [FkFieldConfig] holds all the metadata needed to create an
/// [FkFieldController] and render the appropriate widget, without
/// actually creating either. This makes it ideal for schema-driven
/// form generation.
///
/// ```dart
/// final emailConfig = FkFieldConfig<String>.text(
///   validators: [Fk.required(), Fk.email()],
///   label: 'Email',
///   hint: 'you@example.com',
/// );
///
/// // Later, create a controller from the config:
/// final controller = emailConfig.buildController();
/// ```
class FkFieldConfig<T> {
  /// The type of field this config represents.
  final FkFieldType fieldType;

  /// The initial value for the field, or `null` if none.
  final T? initialValue;

  /// Synchronous validators to run on value changes.
  final List<FkValidator<T>> validators;

  /// Asynchronous validators to run after sync validators pass.
  final List<FkAsyncValidator<T>> asyncValidators;

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

  /// Available options for [FkFieldType.dropdown] fields.
  final List<T>? options;

  /// Display labels for dropdown options, keyed by option value.
  final Map<T, String>? optionLabels;

  /// An optional custom widget builder for [FkFieldType.custom] fields.
  final Widget Function(FkFieldController<T> controller)? widgetBuilder;

  /// Creates an [FkFieldConfig] with full control over all parameters.
  const FkFieldConfig({
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
  /// FkFieldConfig<String>.text(
  ///   validators: [Fk.required(), Fk.email()],
  ///   label: 'Email',
  /// );
  /// ```
  const FkFieldConfig.text({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = FkFieldType.text,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates a password field configuration.
  ///
  /// ```dart
  /// FkFieldConfig<String>.password(
  ///   validators: [Fk.required(), Fk.minLength(8)],
  ///   label: 'Password',
  /// );
  /// ```
  const FkFieldConfig.password({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = FkFieldType.password,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates an email field configuration.
  ///
  /// ```dart
  /// FkFieldConfig<String>.email(
  ///   validators: [Fk.required(), Fk.email()],
  ///   label: 'Email Address',
  /// );
  /// ```
  const FkFieldConfig.email({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = FkFieldType.email,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates a checkbox field configuration.
  ///
  /// ```dart
  /// FkFieldConfig<bool>.checkbox(
  ///   initialValue: false,
  ///   label: 'I agree to the terms',
  ///   validators: [Fk.equals<bool>(true, message: 'Must accept')],
  /// );
  /// ```
  const FkFieldConfig.checkbox({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.enabled = true,
  })  : fieldType = FkFieldType.checkbox,
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
  /// FkFieldConfig<String>.dropdown(
  ///   label: 'Country',
  ///   options: ['US', 'UK', 'CA'],
  ///   optionLabels: {'US': 'United States', 'UK': 'United Kingdom', 'CA': 'Canada'},
  ///   validators: [Fk.required()],
  /// );
  /// ```
  const FkFieldConfig.dropdown({
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
  })  : fieldType = FkFieldType.dropdown,
        widgetBuilder = null;

  /// Creates a date picker field configuration.
  ///
  /// ```dart
  /// FkFieldConfig<DateTime>.date(
  ///   label: 'Birthday',
  ///   validators: [Fk.required<DateTime>()],
  /// );
  /// ```
  const FkFieldConfig.date({
    this.initialValue,
    this.validators = const [],
    this.asyncValidators = const [],
    this.asyncDebounce = const Duration(milliseconds: 400),
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  })  : fieldType = FkFieldType.date,
        options = null,
        optionLabels = null,
        widgetBuilder = null;

  /// Creates an [FkFieldController] from this configuration.
  ///
  /// The returned controller is initialized with the [initialValue],
  /// [validators], [asyncValidators], and [asyncDebounce] defined in
  /// this config.
  ///
  /// ```dart
  /// final config = FkFieldConfig<String>.text(
  ///   initialValue: 'hello',
  ///   validators: [Fk.required()],
  /// );
  /// final controller = config.buildController();
  /// ```
  FkFieldController<T> buildController() {
    return FkFieldController<T>(
      initialValue: initialValue,
      validators: validators,
      asyncValidators: asyncValidators,
      asyncDebounce: asyncDebounce,
      debugLabel: label,
    );
  }
}
