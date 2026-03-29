import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../form/form.dart';
import '../state/bf_field_controller.dart';

/// A signature drawing field using [CustomPainter] and [GestureDetector].
///
/// Bound to [BfFieldController<List<List<Offset>>>] where each inner list is a
/// stroke (an ordered sequence of points). The composite value is a list of
/// strokes, making it easy to replay or serialize the drawing.
///
/// ```dart
/// BfSignatureField(
///   name: 'signature',
///   controller: signatureController,
///   height: 250,
///   strokeColor: Colors.black,
/// )
/// ```
class BfSignatureField extends StatefulWidget {
  /// Creates a signature field bound to [controller].
  const BfSignatureField({
    super.key,
    required this.name,
    required this.controller,
    this.height = 200.0,
    this.strokeColor,
    this.strokeWidth = 2.0,
    this.backgroundColor,
    this.labelText,
    this.enabled = true,
    this.showClearButton = true,
  });

  /// The name used to register this field with an [BfFormController].
  final String name;

  /// The field controller that owns the value and validation state.
  final BfFieldController<List<List<Offset>>> controller;

  /// The height of the signature canvas.
  final double height;

  /// The color used for drawing strokes. Defaults to the theme's primary color.
  final Color? strokeColor;

  /// The width of each stroke line.
  final double strokeWidth;

  /// The background color of the canvas.
  final Color? backgroundColor;

  /// Label text displayed above the signature area.
  final String? labelText;

  /// Whether the field accepts user interaction.
  final bool enabled;

  /// Whether to show a clear button at the top-right corner.
  final bool showClearButton;

  @override
  State<BfSignatureField> createState() => _BfSignatureFieldState();
}

class _BfSignatureFieldState extends State<BfSignatureField> {
  BfFormState? _formState;

  /// The stroke currently being drawn (not yet committed to the controller).
  List<Offset>? _currentStroke;

  // ---------------------------------------------------------------------------
  // Auto-registration (mirrors BfFieldMixin)
  // ---------------------------------------------------------------------------

  String get _fieldName => widget.name;

  BfFieldController<List<List<Offset>>> get _controller => widget.controller;

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
  void didUpdateWidget(covariant BfSignatureField oldWidget) {
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

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled) return;
    _currentStroke = [details.localPosition];
    setState(() {});
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _currentStroke == null) return;
    _currentStroke!.add(details.localPosition);
    setState(() {});
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || _currentStroke == null) return;

    final strokes =
        List<List<Offset>>.from(widget.controller.value ?? <List<Offset>>[]);
    strokes.add(List<Offset>.from(_currentStroke!));
    _currentStroke = null;

    widget.controller.markTouched();
    widget.controller.value = strokes;
  }

  void _onClear() {
    widget.controller.markTouched();
    widget.controller.value = <List<Offset>>[];
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveStrokeColor = widget.strokeColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        widget.backgroundColor ?? theme.colorScheme.surface;
    final errorText =
        bfShouldShowError(controller: _controller, formState: _formState) ? widget.controller.error?.message : null;

    final allStrokes =
        widget.controller.value ?? const <List<Offset>>[];

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
        Stack(
          children: [
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                border: Border.all(
                  color: errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.0),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _SignaturePainter(
                      strokes: allStrokes,
                      currentStroke: _currentStroke,
                      strokeColor: effectiveStrokeColor,
                      strokeWidth: widget.strokeWidth,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showClearButton && widget.enabled && allStrokes.isNotEmpty)
              Positioned(
                top: 4.0,
                right: 4.0,
                child: IconButton(
                  icon: const Icon(Icons.clear, size: 20.0),
                  onPressed: _onClear,
                  tooltip: 'Clear signature',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32.0,
                    minHeight: 32.0,
                  ),
                ),
              ),
          ],
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

/// Custom painter that renders a list of strokes onto a canvas.
///
/// Each stroke is drawn as a continuous [Path] connecting all points in the
/// stroke list.
class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  /// Completed strokes from the controller value.
  final List<List<Offset>> strokes;

  /// The stroke currently being drawn (not yet committed).
  final List<Offset>? currentStroke;

  /// The color used for all strokes.
  final Color strokeColor;

  /// The width of each stroke line.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, paint);
    }

    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!, paint);
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      canvas.drawPoints(
        ui.PointMode.points,
        points,
        paint..style = PaintingStyle.stroke,
      );
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
