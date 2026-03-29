import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A currency input field with locale-aware formatting.
///
/// Bound to [BfFieldController<double>]. The displayed text is automatically
/// formatted with thousand separators and decimal places. Edits strip
/// formatting before parsing to a [double].
///
/// ```dart
/// BfCurrencyField(
///   name: 'price',
///   controller: priceController,
///   symbol: '\$',
///   decimalPlaces: 2,
/// )
/// ```
class BfCurrencyField extends StatefulWidget {
  /// Creates a currency field bound to [controller].
  const BfCurrencyField({
    super.key,
    required this.name,
    required this.controller,
    this.symbol = '\$',
    this.decimalPlaces = 2,
    this.labelText,
    this.hintText,
    this.decoration,
    this.enabled = true,
    this.thousandSeparator = ',',
    this.decimalSeparator = '.',
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<double> controller;

  /// The currency symbol displayed as a prefix (e.g. `'\$'`, `'€'`).
  final String symbol;

  /// The number of digits after the decimal separator.
  final int decimalPlaces;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Optional custom [InputDecoration]. When provided, [labelText] and
  /// [hintText] are ignored.
  final InputDecoration? decoration;

  /// Whether the field accepts user input.
  final bool enabled;

  /// The character used as the thousand grouping separator (e.g. `','`).
  final String thousandSeparator;

  /// The character used as the decimal point (e.g. `'.'`).
  final String decimalSeparator;

  @override
  State<BfCurrencyField> createState() => _BfCurrencyFieldState();
}

class _BfCurrencyFieldState extends State<BfCurrencyField> {
  BfFormState? _formState;

  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  /// Guard flag to prevent infinite update loops between [TextEditingController]
  /// and [BfFieldController].
  bool _isSyncing = false;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
  // ---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = BfForm.maybeOf(context);
    if (newFormState != _formState) {
      _formState?.controller.unregister(widget.name);
      _formState = newFormState;
      _formState?.controller.register(widget.name, widget.controller);
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final initialValue = widget.controller.value;
    _textController = TextEditingController(
      text: initialValue != null ? _formatCurrency(initialValue) : '',
    );

    _focusNode = FocusNode();

    _textController.addListener(_onTextChanged);
    widget.controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant BfCurrencyField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncTextFromController();
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    _formState?.controller.unregister(widget.name);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sync helpers
  // ---------------------------------------------------------------------------

  /// Called when the user types into the [TextField].
  void _onTextChanged() {
    if (_isSyncing) return;
    _isSyncing = true;

    final rawText = _textController.text;
    final parsed = _parseInput(rawText);
    if (widget.controller.value != parsed) {
      widget.controller.value = parsed;
    }

    _isSyncing = false;
  }

  /// Called when the [BfFieldController] changes externally (e.g. reset).
  void _onControllerChanged() {
    _syncTextFromController();
    setState(() {});
  }

  /// Pushes the controller's formatted value into the [TextEditingController].
  void _syncTextFromController() {
    if (_isSyncing) return;
    _isSyncing = true;

    final controllerValue = widget.controller.value;
    final formatted =
        controllerValue != null ? _formatCurrency(controllerValue) : '';
    if (_textController.text != formatted) {
      _textController.text = formatted;
    }

    _isSyncing = false;
  }

  /// Marks the field as touched when focus is lost and formats the display.
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      widget.controller.markTouched();
      // Reformat the text on blur for a clean display.
      _syncTextFromController();
    }
  }

  // ---------------------------------------------------------------------------
  // Formatting & parsing
  // ---------------------------------------------------------------------------

  /// Strips all formatting characters and parses the raw text to a [double].
  ///
  /// Returns `null` for empty or unparsable input.
  double? _parseInput(String text) {
    if (text.isEmpty) return null;

    // Remove thousand separators and replace custom decimal separator with '.'.
    final cleaned = text
        .replaceAll(widget.thousandSeparator, '')
        .replaceAll(widget.decimalSeparator, '.');

    return double.tryParse(cleaned);
  }

  /// Formats a [double] value with thousand separators and the configured
  /// number of decimal places.
  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(widget.decimalPlaces);

    // Split into integer and fractional parts.
    final parts = fixed.split('.');
    final integerPart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';

    // Add thousand separators to the integer part.
    final buffer = StringBuffer();
    final startIndex = integerPart.startsWith('-') ? 1 : 0;
    if (startIndex == 1) buffer.write('-');

    final digits = integerPart.substring(startIndex);
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(widget.thousandSeparator);
      }
      buffer.write(digits[i]);
    }

    if (widget.decimalPlaces > 0) {
      buffer.write(widget.decimalSeparator);
      buffer.write(fractionalPart);
    }

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        bfShouldShowError(controller: widget.controller, formState: _formState) ? widget.controller.error?.message : null;

    final effectiveDecoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        );

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp('[0-9${RegExp.escape(widget.thousandSeparator)}${RegExp.escape(widget.decimalSeparator)}]'),
        ),
      ],
      decoration: effectiveDecoration.copyWith(
        errorText: errorText,
        prefixText: widget.symbol,
      ),
    );
  }
}
