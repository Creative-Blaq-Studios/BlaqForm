import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A switch/toggle field bound to [FkFieldController<bool>].
///
/// Renders a [SwitchListTile] and keeps it synchronized with the provided
/// [FkFieldController]. Validation errors are displayed below the tile when
/// [shouldShowError] is `true`.
class FkSwitchField extends StatefulWidget {
  /// Creates a switch field bound to [controller].
  const FkSwitchField({
    super.key,
    required this.name,
    required this.controller,
    this.label,
    this.subtitle,
    this.enabled = true,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<bool> controller;

  /// Primary label displayed next to the switch.
  final Widget? label;

  /// Optional secondary text displayed below the [label].
  final Widget? subtitle;

  /// Whether the switch accepts user input.
  final bool enabled;

  @override
  State<FkSwitchField> createState() => _FkSwitchFieldState();
}

class _FkSwitchFieldState extends State<FkSwitchField>
    with FkFieldMixin<FkSwitchField, bool> {
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
  void didUpdateWidget(covariant FkSwitchField oldWidget) {
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

  void _onChanged(bool value) {
    widget.controller.value = value;
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
        SwitchListTile(
          value: widget.controller.value ?? false,
          onChanged: widget.enabled ? _onChanged : null,
          title: widget.label,
          subtitle: widget.subtitle,
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
