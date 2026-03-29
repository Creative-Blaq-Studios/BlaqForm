import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../state/bf_field_controller.dart';

/// String convenience extensions on [BfFieldController<String>].
extension BfFieldControllerStringX on BfFieldController<String> {
  /// Returns the current value trimmed of whitespace, or `null` if the value
  /// is `null`.
  String? get trimmed => value?.trim();

  /// Returns the word count of the current value.
  ///
  /// Returns `0` when the value is `null` or empty.
  int get wordCount {
    final v = value?.trim();
    if (v == null || v.isEmpty) return 0;
    return v.split(RegExp(r'\s+')).length;
  }
}

/// Widget builder extension for any [BfFieldController].
extension BfFieldControllerWidgetX<T> on BfFieldController<T> {
  /// Shorthand for building a widget that rebuilds when this controller
  /// changes.
  ///
  /// ```dart
  /// emailController.watch((controller) => Text(controller.value ?? ''))
  /// ```
  Widget watch(Widget Function(BfFieldController<T> controller) builder) {
    return ListenableBuilder(
      listenable: this,
      builder: (context, _) => builder(this),
    );
  }
}

/// PNG export extension for signature field controllers.
extension BfFieldControllerSignatureX
    on BfFieldController<List<List<Offset>>> {
  /// Renders the current strokes to a PNG image and returns the bytes.
  ///
  /// [width] and [height] define the output image dimensions.
  /// [strokeColor] defaults to black. [strokeWidth] defaults to 2.0.
  /// [backgroundColor] defaults to transparent.
  Future<Uint8List> toPng({
    required int width,
    required int height,
    Color strokeColor = const Color(0xFF000000),
    double strokeWidth = 2.0,
    Color backgroundColor = const Color(0x00000000),
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = backgroundColor,
    );

    // Draw strokes
    final paint = Paint()
      ..color = strokeColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final stroke in value ?? <List<Offset>>[]) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawPoints(ui.PointMode.points, stroke, paint);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Renders the current strokes to a PNG and returns it as a base64-encoded
  /// string.
  ///
  /// Accepts the same parameters as [toPng].
  Future<String> toBase64({
    required int width,
    required int height,
    Color strokeColor = const Color(0xFF000000),
    double strokeWidth = 2.0,
    Color backgroundColor = const Color(0x00000000),
  }) async {
    final png = await toPng(
      width: width,
      height: height,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      backgroundColor: backgroundColor,
    );
    return base64Encode(png);
  }
}
