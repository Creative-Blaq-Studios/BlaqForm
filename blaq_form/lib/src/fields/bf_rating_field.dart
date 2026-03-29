import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A star rating field bound to [BfFieldController<double>].
///
/// Renders a row of tappable star icons. Supports whole and half-star ratings.
///
/// ```dart
/// BfRatingField(
///   name: 'rating',
///   controller: ratingController,
///   maxRating: 5,
///   allowHalfRating: true,
/// )
/// ```
class BfRatingField extends StatefulWidget {
  /// Creates a star rating field bound to [controller].
  const BfRatingField({
    super.key,
    required this.name,
    required this.controller,
    this.maxRating = 5,
    this.allowHalfRating = false,
    this.size = 36.0,
    this.color,
    this.unratedColor,
    this.labelText,
    this.enabled = true,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<double> controller;

  /// The maximum number of stars displayed.
  final int maxRating;

  /// Whether half-star ratings are allowed.
  ///
  /// When `true`, tapping the left half of a star sets a `.5` value, while
  /// tapping the right half sets a whole number value.
  final bool allowHalfRating;

  /// The size of each star icon in logical pixels.
  final double size;

  /// The color for filled (rated) stars.
  ///
  /// Defaults to [ColorScheme.primary].
  final Color? color;

  /// The color for unfilled (unrated) stars.
  ///
  /// Defaults to `Colors.grey.shade300`.
  final Color? unratedColor;

  /// Label text displayed above the stars.
  final String? labelText;

  /// Whether the field accepts user interaction.
  final bool enabled;

  @override
  State<BfRatingField> createState() => _BfRatingFieldState();
}

class _BfRatingFieldState extends State<BfRatingField> {
  BfFormState? _formState;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<double> get _controller => widget.controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newFormState = BfForm.maybeOf(context);
    if (newFormState != _formState) {
      _formState?.controller.unregister(_fieldName);
      _formState = newFormState;
      _formState?.controller.register(_fieldName, _controller);
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BfRatingField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _formState?.controller.unregister(_fieldName);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Callbacks
  // ---------------------------------------------------------------------------

  void _onControllerChanged() {
    setState(() {});
  }

  void _onStarTap(int starIndex, Offset localPosition) {
    if (!widget.enabled) return;

    _controller.markTouched();

    if (widget.allowHalfRating) {
      final isLeftHalf = localPosition.dx < widget.size / 2;
      _controller.value = isLeftHalf ? starIndex + 0.5 : starIndex + 1.0;
    } else {
      _controller.value = starIndex + 1.0;
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentRating = _controller.value ?? 0.0;
    final ratedColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final emptyColor = widget.unratedColor ?? Colors.grey.shade300;
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState) ? _controller.error?.message : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.labelText!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxRating, (index) {
            return _BfStar(
              index: index,
              currentRating: currentRating,
              size: widget.size,
              ratedColor: ratedColor,
              unratedColor: emptyColor,
              enabled: widget.enabled,
              onTapDown: (details) =>
                  _onStarTap(index, details.localPosition),
            );
          }),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
      ],
    );
  }
}

/// A single star within the [BfRatingField] row.
///
/// Displays a filled, half-filled, or empty star icon depending on the
/// [currentRating] relative to this star's [index].
class _BfStar extends StatelessWidget {
  const _BfStar({
    required this.index,
    required this.currentRating,
    required this.size,
    required this.ratedColor,
    required this.unratedColor,
    required this.enabled,
    required this.onTapDown,
  });

  /// Zero-based index of this star in the row.
  final int index;

  /// The current rating value from the controller.
  final double currentRating;

  /// The icon size in logical pixels.
  final double size;

  /// Color for filled portions.
  final Color ratedColor;

  /// Color for unfilled portions.
  final Color unratedColor;

  /// Whether tap interaction is enabled.
  final bool enabled;

  /// Called when the user taps down on this star.
  final GestureTapDownCallback onTapDown;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color color;

    if (currentRating >= index + 1) {
      icon = Icons.star;
      color = ratedColor;
    } else if (currentRating >= index + 0.5) {
      icon = Icons.star_half;
      color = ratedColor;
    } else {
      icon = Icons.star_border;
      color = unratedColor;
    }

    return GestureDetector(
      onTapDown: enabled ? onTapDown : null,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}
