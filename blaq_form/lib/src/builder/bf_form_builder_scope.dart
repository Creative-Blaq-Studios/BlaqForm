import 'package:flutter/material.dart';

import '../fields/bf_checkbox_field.dart';
import '../fields/bf_date_field.dart';
import '../fields/bf_dropdown_field.dart';
import '../fields/bf_switch_field.dart';
import '../fields/bf_text_field.dart';
import '../layout/bf_submit_button.dart';
import '../state/bf_field_controller.dart';
import '../state/bf_form_controller.dart';
import 'bf_field_config.dart';

/// A proxy object passed to the [BfFormBuilder]'s `builder` callback.
///
/// Provides fluent methods that return pre-wired field widgets without
/// manual controller management. Each method reads the [BfFieldConfig]
/// for defaults (label, hint, prefixIcon, etc.) but allows per-callsite
/// overrides.
///
/// ```dart
/// BfFormBuilder(
///   fields: {'name': BfFieldConfig<String>.text(label: 'Name')},
///   builder: (scope) => Column(children: [
///     scope.text('name'),
///     scope.submitButton('Save'),
///   ]),
/// )
/// ```
class BfFormBuilderScope {
  /// Creates a scope with access to the form controller, field controllers,
  /// and field configurations.
  BfFormBuilderScope({
    required this.formController,
    required Map<String, BfFieldController> controllers,
    required Map<String, BfFieldConfig> configs,
  }) : _controllers = controllers,
       _configs = configs;

  /// The form controller managing all registered fields.
  final BfFormController formController;

  final Map<String, BfFieldController> _controllers;
  final Map<String, BfFieldConfig> _configs;

  /// An optional callback invoked by the default [submitButton] when
  /// [BfFormBuilder.onSubmit] is provided.
  Future<void> Function(Map<String, dynamic> values)? onSubmit;

  /// Returns the typed [BfFieldController] for the given field [name].
  ///
  /// Throws a [StateError] if no controller with that name exists.
  BfFieldController<T> controller<T>(String name) {
    final ctrl = _controllers[name];
    if (ctrl == null) {
      throw StateError(
        'BfFormBuilderScope: no controller found for field "$name". '
        'Make sure "$name" is declared in the fields map.',
      );
    }
    return ctrl as BfFieldController<T>;
  }

  /// Returns a map of all field names to their current values.
  Map<String, dynamic> get values => formController.toMap();

  // ---------------------------------------------------------------------------
  // Field builders
  // ---------------------------------------------------------------------------

  /// Returns an [BfTextField] for the field named [name].
  ///
  /// Config-level defaults for label, hint, prefixIcon, suffixIcon, and
  /// enabled are used unless overridden.
  BfTextField text(
    String name, {
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? enabled,
    InputDecoration? decoration,
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    Key? key,
  }) {
    final config = _configs[name];
    return BfTextField(
      key: key,
      name: name,
      controller: controller<String>(name),
      labelText: label ?? config?.label,
      hintText: hint ?? config?.hint,
      prefixIcon: prefixIcon ?? _resolveIcon(config?.prefixIcon),
      suffixIcon: suffixIcon ?? _resolveIcon(config?.suffixIcon),
      enabled: enabled ?? config?.enabled ?? true,
      decoration: decoration,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
    );
  }

  /// Returns a password [BfTextField] for the field named [name].
  BfTextField password(
    String name, {
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? enabled,
    InputDecoration? decoration,
    Key? key,
  }) {
    final config = _configs[name];
    return BfTextField.password(
      key: key,
      name: name,
      controller: controller<String>(name),
      labelText: label ?? config?.label,
      hintText: hint ?? config?.hint,
      prefixIcon: prefixIcon ?? _resolveIcon(config?.prefixIcon),
      suffixIcon: suffixIcon ?? _resolveIcon(config?.suffixIcon),
      enabled: enabled ?? config?.enabled ?? true,
      decoration: decoration,
    );
  }

  /// Returns an email [BfTextField] for the field named [name].
  BfTextField email(
    String name, {
    String? label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? enabled,
    InputDecoration? decoration,
    Key? key,
  }) {
    final config = _configs[name];
    return BfTextField.email(
      key: key,
      name: name,
      controller: controller<String>(name),
      labelText: label ?? config?.label,
      hintText: hint ?? config?.hint,
      prefixIcon: prefixIcon ?? _resolveIcon(config?.prefixIcon),
      suffixIcon: suffixIcon ?? _resolveIcon(config?.suffixIcon),
      enabled: enabled ?? config?.enabled ?? true,
      decoration: decoration,
    );
  }

  /// Returns an [BfCheckboxField] for the field named [name].
  BfCheckboxField checkbox(
    String name, {
    String? label,
    Widget? subtitle,
    bool? enabled,
    bool tristate = false,
    Key? key,
  }) {
    final config = _configs[name];
    return BfCheckboxField(
      key: key,
      name: name,
      controller: controller<bool>(name),
      label: label != null
          ? Text(label)
          : (config?.label != null ? Text(config!.label!) : null),
      subtitle: subtitle,
      enabled: enabled ?? config?.enabled ?? true,
      tristate: tristate,
    );
  }

  /// Returns an [BfSwitchField] for the field named [name].
  BfSwitchField switchField(
    String name, {
    String? label,
    Widget? subtitle,
    bool? enabled,
    Key? key,
  }) {
    final config = _configs[name];
    return BfSwitchField(
      key: key,
      name: name,
      controller: controller<bool>(name),
      label: label != null
          ? Text(label)
          : (config?.label != null ? Text(config!.label!) : null),
      subtitle: subtitle,
      enabled: enabled ?? config?.enabled ?? true,
    );
  }

  /// Returns an [BfDropdownField] for the field named [name].
  ///
  /// If the config has [BfFieldConfig.options], they are automatically
  /// converted to [DropdownMenuItem]s using [BfFieldConfig.optionLabels]
  /// for display text.
  BfDropdownField<T> dropdown<T>(
    String name, {
    List<DropdownMenuItem<T>>? items,
    String? label,
    String? hint,
    bool? enabled,
    InputDecoration? decoration,
    Key? key,
  }) {
    final config = _configs[name] as BfFieldConfig<T>?;

    // Build items from config options if not provided explicitly.
    final effectiveItems =
        items ??
        (config?.options?.map((option) {
              final displayText =
                  config.optionLabels?[option] ?? option.toString();
              return DropdownMenuItem<T>(
                value: option,
                child: Text(displayText),
              );
            }).toList() ??
            <DropdownMenuItem<T>>[]);

    return BfDropdownField<T>(
      key: key,
      name: name,
      controller: controller<T>(name),
      items: effectiveItems,
      labelText: label ?? config?.label,
      hintText: hint ?? config?.hint,
      enabled: enabled ?? config?.enabled ?? true,
      decoration: decoration,
    );
  }

  /// Returns an [BfDateField] for the field named [name].
  BfDateField date(
    String name, {
    String? label,
    String? hint,
    DateTime? firstDate,
    DateTime? lastDate,
    String? dateFormat,
    bool? enabled,
    InputDecoration? decoration,
    Key? key,
  }) {
    final config = _configs[name];
    return BfDateField(
      key: key,
      name: name,
      controller: controller<DateTime>(name),
      labelText: label ?? config?.label,
      hintText: hint ?? config?.hint,
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      enabled: enabled ?? config?.enabled ?? true,
      decoration: decoration,
    );
  }

  /// Returns an [BfSubmitButton] wired to the form controller.
  ///
  /// If [onSubmit] is provided at the callsite it takes precedence;
  /// otherwise the scope-level [onSubmit] (from [BfFormBuilder]) is used.
  BfSubmitButton submitButton(
    String label, {
    Future<void> Function(Map<String, dynamic> values)? onSubmit,
    bool disableWhenInvalid = true,
    ButtonStyle? style,
    Key? key,
  }) {
    final effectiveOnSubmit = onSubmit ?? this.onSubmit;
    return BfSubmitButton(
      key: key,
      label: label,
      disableWhenInvalid: disableWhenInvalid,
      style: style,
      onSubmit: (controller) async {
        if (effectiveOnSubmit != null) {
          await controller.submit(effectiveOnSubmit);
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Converts an [IconData] to an [Icon] widget, or returns `null`.
  Widget? _resolveIcon(IconData? iconData) {
    if (iconData == null) return null;
    return Icon(iconData);
  }
}
