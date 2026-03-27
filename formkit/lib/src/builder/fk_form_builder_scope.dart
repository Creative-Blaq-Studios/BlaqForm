import 'package:flutter/material.dart';

import '../fields/fk_checkbox_field.dart';
import '../fields/fk_date_field.dart';
import '../fields/fk_dropdown_field.dart';
import '../fields/fk_switch_field.dart';
import '../fields/fk_text_field.dart';
import '../layout/fk_submit_button.dart';
import '../state/fk_field_controller.dart';
import '../state/fk_form_controller.dart';
import 'fk_field_config.dart';

/// A proxy object passed to the [FkFormBuilder]'s `builder` callback.
///
/// Provides fluent methods that return pre-wired field widgets without
/// manual controller management. Each method reads the [FkFieldConfig]
/// for defaults (label, hint, prefixIcon, etc.) but allows per-callsite
/// overrides.
///
/// ```dart
/// FkFormBuilder(
///   fields: {'name': FkFieldConfig<String>.text(label: 'Name')},
///   builder: (scope) => Column(children: [
///     scope.text('name'),
///     scope.submitButton('Save'),
///   ]),
/// )
/// ```
class FkFormBuilderScope {
  /// Creates a scope with access to the form controller, field controllers,
  /// and field configurations.
  FkFormBuilderScope({
    required this.formController,
    required Map<String, FkFieldController> controllers,
    required Map<String, FkFieldConfig> configs,
  })  : _controllers = controllers,
        _configs = configs;

  /// The form controller managing all registered fields.
  final FkFormController formController;

  final Map<String, FkFieldController> _controllers;
  final Map<String, FkFieldConfig> _configs;

  /// An optional callback invoked by the default [submitButton] when
  /// [FkFormBuilder.onSubmit] is provided.
  Future<void> Function(Map<String, dynamic> values)? onSubmit;

  /// Returns the typed [FkFieldController] for the given field [name].
  ///
  /// Throws a [StateError] if no controller with that name exists.
  FkFieldController<T> controller<T>(String name) {
    final ctrl = _controllers[name];
    if (ctrl == null) {
      throw StateError(
        'FkFormBuilderScope: no controller found for field "$name". '
        'Make sure "$name" is declared in the fields map.',
      );
    }
    return ctrl as FkFieldController<T>;
  }

  /// Returns a map of all field names to their current values.
  Map<String, dynamic> get values => formController.toMap();

  // ---------------------------------------------------------------------------
  // Field builders
  // ---------------------------------------------------------------------------

  /// Returns an [FkTextField] for the field named [name].
  ///
  /// Config-level defaults for label, hint, prefixIcon, suffixIcon, and
  /// enabled are used unless overridden.
  FkTextField text(
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
    return FkTextField(
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

  /// Returns a password [FkTextField] for the field named [name].
  FkTextField password(
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
    return FkTextField.password(
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

  /// Returns an email [FkTextField] for the field named [name].
  FkTextField email(
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
    return FkTextField.email(
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

  /// Returns an [FkCheckboxField] for the field named [name].
  FkCheckboxField checkbox(
    String name, {
    String? label,
    Widget? subtitle,
    bool? enabled,
    bool tristate = false,
    Key? key,
  }) {
    final config = _configs[name];
    return FkCheckboxField(
      key: key,
      name: name,
      controller: controller<bool>(name),
      label: label != null ? Text(label) : (config?.label != null ? Text(config!.label!) : null),
      subtitle: subtitle,
      enabled: enabled ?? config?.enabled ?? true,
      tristate: tristate,
    );
  }

  /// Returns an [FkSwitchField] for the field named [name].
  FkSwitchField switchField(
    String name, {
    String? label,
    Widget? subtitle,
    bool? enabled,
    Key? key,
  }) {
    final config = _configs[name];
    return FkSwitchField(
      key: key,
      name: name,
      controller: controller<bool>(name),
      label: label != null ? Text(label) : (config?.label != null ? Text(config!.label!) : null),
      subtitle: subtitle,
      enabled: enabled ?? config?.enabled ?? true,
    );
  }

  /// Returns an [FkDropdownField] for the field named [name].
  ///
  /// If the config has [FkFieldConfig.options], they are automatically
  /// converted to [DropdownMenuItem]s using [FkFieldConfig.optionLabels]
  /// for display text.
  FkDropdownField<T> dropdown<T>(
    String name, {
    List<DropdownMenuItem<T>>? items,
    String? label,
    String? hint,
    bool? enabled,
    InputDecoration? decoration,
    Key? key,
  }) {
    final config = _configs[name] as FkFieldConfig<T>?;

    // Build items from config options if not provided explicitly.
    final effectiveItems = items ??
        (config?.options?.map((option) {
          final displayText =
              config.optionLabels?[option] ?? option.toString();
          return DropdownMenuItem<T>(
            value: option,
            child: Text(displayText),
          );
        }).toList() ??
        <DropdownMenuItem<T>>[]);

    return FkDropdownField<T>(
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

  /// Returns an [FkDateField] for the field named [name].
  FkDateField date(
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
    return FkDateField(
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

  /// Returns an [FkSubmitButton] wired to the form controller.
  ///
  /// If [onSubmit] is provided at the callsite it takes precedence;
  /// otherwise the scope-level [onSubmit] (from [FkFormBuilder]) is used.
  FkSubmitButton submitButton(
    String label, {
    Future<void> Function(Map<String, dynamic> values)? onSubmit,
    bool disableWhenInvalid = true,
    ButtonStyle? style,
    Key? key,
  }) {
    final effectiveOnSubmit = onSubmit ?? this.onSubmit;
    return FkSubmitButton(
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
