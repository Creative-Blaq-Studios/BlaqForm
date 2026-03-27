import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A built-in list of common country dial codes.
///
/// Each entry is a record of `(code, name)` where `code` is the dial prefix
/// (e.g. `'+1'`) and `name` is the ISO country identifier.
const List<({String code, String name})> _kDefaultCountries = [
  (code: '+1', name: 'US'),
  (code: '+1', name: 'CA'),
  (code: '+44', name: 'UK'),
  (code: '+61', name: 'AU'),
  (code: '+91', name: 'IN'),
  (code: '+49', name: 'DE'),
  (code: '+33', name: 'FR'),
  (code: '+81', name: 'JP'),
  (code: '+86', name: 'CN'),
  (code: '+55', name: 'BR'),
  (code: '+52', name: 'MX'),
  (code: '+82', name: 'KR'),
  (code: '+39', name: 'IT'),
  (code: '+34', name: 'ES'),
  (code: '+31', name: 'NL'),
  (code: '+46', name: 'SE'),
  (code: '+47', name: 'NO'),
  (code: '+45', name: 'DK'),
  (code: '+358', name: 'FI'),
  (code: '+48', name: 'PL'),
];

/// A phone number input with a country code selector.
///
/// The controller holds the full phone string as `"$dialCode$number"`
/// (e.g. `"+14155551234"`). The country code selector is rendered as a
/// [DropdownButton] prefix inside the [TextField].
///
/// ```dart
/// FkPhoneField(
///   name: 'phone',
///   controller: phoneController,
///   defaultCountryCode: '+1',
/// )
/// ```
class FkPhoneField extends StatefulWidget {
  /// Creates a phone field bound to [controller].
  const FkPhoneField({
    super.key,
    required this.name,
    required this.controller,
    this.defaultCountryCode = '+1',
    this.labelText,
    this.hintText,
    this.decoration,
    this.enabled = true,
    this.countries,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<String> controller;

  /// The initial country dial code (e.g. `'+1'`).
  final String defaultCountryCode;

  /// Label text displayed above or within the field.
  final String? labelText;

  /// Placeholder text shown when the field is empty.
  final String? hintText;

  /// Optional custom [InputDecoration]. When provided, [labelText] and
  /// [hintText] are ignored.
  final InputDecoration? decoration;

  /// Whether the field accepts user input.
  final bool enabled;

  /// An optional custom list of country entries.
  ///
  /// Each entry is a record of `(code, name)`. If `null`, a built-in list
  /// of ~20 common countries is used.
  final List<({String code, String name})>? countries;

  @override
  State<FkPhoneField> createState() => _FkPhoneFieldState();
}

class _FkPhoneFieldState extends State<FkPhoneField> {
  FkFormState? _formState;

  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late String _selectedDialCode;

  /// Guard flag to prevent infinite update loops.
  bool _isSyncing = false;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors FkFieldMixin)
  // ---------------------------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = FkForm.maybeOf(context);
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

    _selectedDialCode = widget.defaultCountryCode;

    // Parse existing controller value to extract dial code and number.
    final initial = widget.controller.value ?? '';
    final parsed = _parsePhoneValue(initial);
    if (parsed != null) {
      _selectedDialCode = parsed.dialCode;
      _textController = TextEditingController(text: parsed.number);
    } else {
      _textController = TextEditingController();
    }

    _focusNode = FocusNode();

    _textController.addListener(_onTextChanged);
    widget.controller.addListener(_onControllerChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant FkPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncFromController();
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
    _pushCombinedValue();
    _isSyncing = false;
  }

  /// Called when the [FkFieldController] changes externally (e.g. reset).
  void _onControllerChanged() {
    _syncFromController();
    setState(() {});
  }

  /// Pushes the combined dial code + number into the controller.
  void _pushCombinedValue() {
    final number = _textController.text;
    final combined = number.isEmpty ? '' : '$_selectedDialCode$number';
    if (widget.controller.value != combined) {
      widget.controller.value = combined;
    }
  }

  /// Pulls the controller value and distributes to dial code selector + text.
  void _syncFromController() {
    if (_isSyncing) return;
    _isSyncing = true;

    final value = widget.controller.value ?? '';
    if (value.isEmpty) {
      _textController.text = '';
    } else {
      final parsed = _parsePhoneValue(value);
      if (parsed != null) {
        _selectedDialCode = parsed.dialCode;
        if (_textController.text != parsed.number) {
          _textController.text = parsed.number;
        }
      }
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
  // Parsing
  // ---------------------------------------------------------------------------

  /// The effective list of countries to display.
  List<({String code, String name})> get _countries =>
      widget.countries ?? _kDefaultCountries;

  /// Attempts to parse a combined phone value like `"+4412345"` into its
  /// dial code and number components by matching against known country codes.
  ({String dialCode, String number})? _parsePhoneValue(String value) {
    if (value.isEmpty || !value.startsWith('+')) return null;

    // Try longest codes first for correct matching (e.g. +358 before +3).
    final codes = _countries.map((c) => c.code).toSet().toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final code in codes) {
      if (value.startsWith(code)) {
        return (dialCode: code, number: value.substring(code.length));
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final errorText =
        fkShouldShowError(controller: widget.controller, formState: _formState) ? widget.controller.error?.message : null;

    // Build unique dropdown items. Multiple countries can share a code (US/CA),
    // so show "code (name)" for disambiguation.
    final countries = _countries;

    final effectiveDecoration = widget.decoration ??
        InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        );

    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: effectiveDecoration.copyWith(
        errorText: errorText,
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedDialCode,
              isDense: true,
              items: countries
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c.code,
                      child: Text('${c.code} (${c.name})'),
                    ),
                  )
                  .toList(),
              onChanged: widget.enabled
                  ? (value) {
                      if (value != null && value != _selectedDialCode) {
                        setState(() {
                          _selectedDialCode = value;
                        });
                        _isSyncing = true;
                        _pushCombinedValue();
                        _isSyncing = false;
                      }
                    }
                  : null,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
      ),
    );
  }
}
