import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../form/form.dart';
import '../state/fk_field_controller.dart';

/// A multi-box OTP/PIN input field.
///
/// Each digit occupies its own input box. Focus automatically advances to the
/// next box on input and retreats on backspace when the current box is empty.
/// The concatenated digits are stored in the bound [FkFieldController<String>].
///
/// ```dart
/// FkOtpField(
///   name: 'otp',
///   controller: otpController,
///   length: 6,
/// )
/// ```
class FkOtpField extends StatefulWidget {
  /// Creates an OTP field bound to [controller].
  const FkOtpField({
    super.key,
    required this.name,
    required this.controller,
    this.length = 6,
    this.obscureText = false,
    this.labelText,
    this.enabled = true,
    this.boxWidth = 48.0,
    this.boxHeight = 56.0,
    this.spacing = 8.0,
    this.autofocus = false,
  });

  /// The name used to register this field with an [FkFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final FkFieldController<String> controller;

  /// The number of digit boxes to display.
  final int length;

  /// Whether to obscure the entered digits (e.g. for PIN entry).
  final bool obscureText;

  /// Optional label text displayed above the row of boxes.
  final String? labelText;

  /// Whether the field accepts user input.
  final bool enabled;

  /// The width of each individual digit box.
  final double boxWidth;

  /// The height of each individual digit box.
  final double boxHeight;

  /// The horizontal spacing between digit boxes.
  final double spacing;

  /// Whether the first box should receive focus automatically.
  final bool autofocus;

  @override
  State<FkOtpField> createState() => _FkOtpFieldState();
}

class _FkOtpFieldState extends State<FkOtpField> {
  FkFormState? _formState;

  late List<TextEditingController> _boxControllers;
  late List<FocusNode> _focusNodes;
  late List<FocusNode> _keyListenerFocusNodes;

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
    _initBoxes();
    widget.controller.addListener(_onControllerChanged);

    // Distribute existing controller value into boxes.
    _syncBoxesFromController();
  }

  @override
  void didUpdateWidget(covariant FkOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      _syncBoxesFromController();
    }

    if (oldWidget.length != widget.length) {
      _disposeBoxes();
      _initBoxes();
      _syncBoxesFromController();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _disposeBoxes();
    _formState?.controller.unregister(widget.name);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  /// Creates the internal [TextEditingController]s and [FocusNode]s for each
  /// digit box.
  void _initBoxes() {
    _boxControllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
    _keyListenerFocusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );
  }

  /// Disposes all internal controllers and focus nodes.
  void _disposeBoxes() {
    for (final c in _boxControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final f in _keyListenerFocusNodes) {
      f.dispose();
    }
  }

  /// Concatenates all box values and pushes the result into the
  /// [FkFieldController].
  void _pushCombinedValue() {
    final combined = _boxControllers.map((c) => c.text).join();
    if (widget.controller.value != combined) {
      widget.controller.value = combined;
    }
  }

  /// Distributes the controller's current value across the individual boxes.
  void _syncBoxesFromController() {
    if (_isSyncing) return;
    _isSyncing = true;

    final value = widget.controller.value ?? '';
    for (var i = 0; i < widget.length; i++) {
      final char = i < value.length ? value[i] : '';
      if (_boxControllers[i].text != char) {
        _boxControllers[i].text = char;
      }
    }

    _isSyncing = false;
  }

  /// Called when the [FkFieldController] changes externally (e.g. reset).
  void _onControllerChanged() {
    _syncBoxesFromController();
    setState(() {});
  }

  /// Handles input in a single digit box.
  void _onBoxChanged(int index, String value) {
    if (_isSyncing) return;
    _isSyncing = true;

    // If a multi-character paste, distribute across boxes.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < widget.length; i++) {
        final char = (index + i) < digits.length + index && i < digits.length
            ? digits[i]
            : '';
        if (i + index < widget.length) {
          _boxControllers[i + index].text = char;
        }
      }
      final nextIndex = (index + digits.length).clamp(0, widget.length - 1);
      _focusNodes[nextIndex].requestFocus();
    } else if (value.length == 1) {
      // Advance to next box.
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    }

    _pushCombinedValue();
    _isSyncing = false;
  }

  /// Handles key events to detect backspace on an empty box, which should
  /// retreat focus to the previous box.
  KeyEventResult _onBoxKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_boxControllers[index].text.isEmpty && index > 0) {
        _boxControllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();

        if (!_isSyncing) {
          _isSyncing = true;
          _pushCombinedValue();
          _isSyncing = false;
        }

        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText =
        fkShouldShowError(controller: widget.controller, formState: _formState) ? widget.controller.error?.message : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (index) {
            final isLast = index == widget.length - 1;
            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : widget.spacing),
              child: SizedBox(
                width: widget.boxWidth,
                height: widget.boxHeight,
                child: KeyboardListener(
                  focusNode: _keyListenerFocusNodes[index],
                  onKeyEvent: (event) => _onBoxKeyEvent(index, event),
                  child: TextField(
                    controller: _boxControllers[index],
                    focusNode: _focusNodes[index],
                    enabled: widget.enabled,
                    autofocus: widget.autofocus && index == 0,
                    obscureText: widget.obscureText,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: errorText != null
                              ? theme.colorScheme.error
                              : theme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: errorText != null
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onBoxChanged(index, value),
                    onTap: () {
                      // Select existing text so next input replaces it.
                      final ctrl = _boxControllers[index];
                      if (ctrl.text.isNotEmpty) {
                        ctrl.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: ctrl.text.length,
                        );
                      }
                      widget.controller.markTouched();
                    },
                  ),
                ),
              ),
            );
          }),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12.0),
            child: Text(
              errorText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
