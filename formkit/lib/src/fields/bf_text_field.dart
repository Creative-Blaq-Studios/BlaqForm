import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';
import '../theme/bf_form_theme.dart';

/// A text input field that integrates with [BfFieldController<String>].
///
/// Wraps a standard [TextField] and keeps it in sync with the provided
/// [BfFieldController]. Validation errors are displayed automatically when
/// [shouldShowError] is `true` (i.e. the field has been touched or the form
/// has been submitted).
///
/// Use the convenience constructors [BfTextField.password] and
/// [BfTextField.email] for common field configurations.
class BfTextField extends StatefulWidget {
  /// Creates a text field bound to [controller].
  const BfTextField({
    super.key,
    required this.name,
    required this.controller,
    this.decoration,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
  });

  /// Convenience constructor for password fields.
  ///
  /// Sets [obscureText] to `true` and [maxLines] to `1`.
  BfTextField.password({
    super.key,
    required this.name,
    required this.controller,
    this.decoration,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
  })  : obscureText = true,
        maxLines = 1;

  /// Convenience constructor for email fields.
  ///
  /// Sets [keyboardType] to [TextInputType.emailAddress].
  BfTextField.email({
    super.key,
    required this.name,
    required this.controller,
    this.decoration,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.labelText,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.focusNode,
  }) : keyboardType = TextInputType.emailAddress;

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<String> controller;

  /// Optional custom [InputDecoration]. When provided, [prefixIcon],
  /// [suffixIcon], [hintText], and [labelText] are ignored.
  final InputDecoration? decoration;

  /// Whether to hide the text being entered (e.g. for passwords).
  final bool obscureText;

  /// The maximum number of lines for the text field.
  final int maxLines;

  /// The minimum number of lines for the text field.
  final int? minLines;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// The action button on the keyboard (e.g. done, next).
  final TextInputAction? textInputAction;

  /// Optional formatters that constrain input (e.g. digits only).
  final List<TextInputFormatter>? inputFormatters;

  /// Autofill hints for the platform (e.g. [AutofillHints.email]).
  final Iterable<String>? autofillHints;

  /// An icon displayed before the input area.
  final Widget? prefixIcon;

  /// An icon displayed after the input area.
  final Widget? suffixIcon;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Whether the field accepts user input.
  final bool enabled;

  /// Whether the field is read-only (focusable but not editable).
  final bool readOnly;

  /// Optional callback invoked when the text changes.
  final ValueChanged<String>? onChanged;

  /// An optional external [FocusNode].
  final FocusNode? focusNode;

  @override
  State<BfTextField> createState() => _BfTextFieldState();
}

class _BfTextFieldState extends State<BfTextField>
    with BfFieldMixin<BfTextField, String> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _ownsFocusNode = false;

  /// Guard flag to prevent infinite update loops between [TextEditingController]
  /// and [BfFieldController].
  bool _isSyncing = false;

  @override
  String get fieldName => widget.name;

  @override
  BfFieldController<String> get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController(
      text: widget.controller.value ?? '',
    );

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }

    _textController.addListener(_onTextChanged);
    widget.controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant BfTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncTextFromController();
    }

    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
        _ownsFocusNode = false;
      }

      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
      } else {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      }
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sync helpers
  // ---------------------------------------------------------------------------

  /// Called when the user types into the [TextField].
  void _onTextChanged() {
    if (_isSyncing) return;
    _isSyncing = true;
    final text = _textController.text;
    if (widget.controller.value != text) {
      widget.controller.value = text;
      widget.onChanged?.call(text);
    }
    _isSyncing = false;
  }

  /// Called when the [BfFieldController] changes externally (e.g. reset).
  void _onControllerChanged() {
    _syncTextFromController();
    setState(() {});
  }

  /// Pushes the controller's value into the [TextEditingController] if they
  /// differ, without triggering a reverse update.
  void _syncTextFromController() {
    if (_isSyncing) return;
    _isSyncing = true;
    final controllerText = widget.controller.value ?? '';
    if (_textController.text != controllerText) {
      _textController.text = controllerText;
    }
    _isSyncing = false;
  }

  /// Marks the field as touched when focus is lost.
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      widget.controller.markTouched();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final fkTheme = BfFormTheme.of(context);
    final errorText =
        shouldShowError ? widget.controller.error?.message : null;

    final baseDecoration = fkTheme.inputDecoration ?? const InputDecoration();
    final effectiveDecoration = widget.decoration ??
        baseDecoration.copyWith(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: fkTheme.hintStyle,
          labelStyle: fkTheme.labelStyle,
          errorStyle: fkTheme.errorStyle,
        );

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      decoration: effectiveDecoration.copyWith(errorText: errorText),
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
    );
  }
}
