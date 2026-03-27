import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A single checkbox field bound to [FkFieldController<bool>].
///
/// Renders a [CheckboxListTile] and keeps it synchronized with the provided
/// [FkFieldController]. Validation errors are displayed below the tile when
/// [shouldShowError] is `true`.
class FkCheckboxField extends StatefulWidget {
  /// Creates a checkbox field bound to [controller].
  const FkCheckboxField({
    super.key,
    required this.name,
    required this.controller,
    this.label,
    this.subtitle,
    this.enabled = true,
    this.tristate = false,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<bool> controller;

  /// Primary label displayed next to the checkbox.
  final Widget? label;

  /// Optional secondary text displayed below the [label].
  final Widget? subtitle;

  /// Whether the checkbox accepts user input.
  final bool enabled;

  /// Whether the checkbox supports three states (checked, unchecked,
  /// indeterminate).
  final bool tristate;

  @override
  State<FkCheckboxField> createState() => _FkCheckboxFieldState();
}

class _FkCheckboxFieldState extends State<FkCheckboxField>
    with FkFieldMixin<FkCheckboxField, bool> {
  @override
  String get fieldName => widget.name;

  @override
  FkFieldController<bool> get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant FkCheckboxField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onChanged(bool? value) {
    widget.controller.value = value ?? false;
    widget.controller.markTouched();
  }

  @override
  Widget build(BuildContext context) {
    final errorText =
        shouldShowError ? widget.controller.error?.message : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
          value: widget.controller.value ?? false,
          onChanged: widget.enabled ? _onChanged : null,
          title: widget.label,
          subtitle: widget.subtitle,
          tristate: widget.tristate,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
