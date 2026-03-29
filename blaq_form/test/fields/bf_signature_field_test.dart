import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BfSignatureField', () {
    testWidgets('renders a canvas container', (tester) async {
      final controller = BfFieldController<List<List<Offset>>>();

      await tester.pumpWidget(buildTestForm(
        child: BfSignatureField(
          name: 'sig',
          controller: controller,
        ),
      ));

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('records a stroke on pan gesture', (tester) async {
      final controller = BfFieldController<List<List<Offset>>>();

      await tester.pumpWidget(buildTestForm(
        child: BfSignatureField(
          name: 'sig',
          controller: controller,
          height: 200,
        ),
      ));

      // Find the GestureDetector within the signature field's ClipRRect
      final gestureDetector = find.byType(GestureDetector).first;
      final center = tester.getCenter(gestureDetector);

      final gesture = await tester.startGesture(center);
      await tester.pump();
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      expect(controller.value, isNotNull);
      expect(controller.value!.length, 1); // one stroke
      expect(controller.value!.first.length, greaterThanOrEqualTo(2));
    });

    testWidgets('clear button resets to empty strokes', (tester) async {
      final controller = BfFieldController<List<List<Offset>>>(
        initialValue: [
          [const Offset(0, 0), const Offset(10, 10)],
        ],
      );

      await tester.pumpWidget(buildTestForm(
        child: BfSignatureField(
          name: 'sig',
          controller: controller,
          showClearButton: true,
        ),
      ));

      // Clear button should appear when strokes exist
      expect(find.byIcon(Icons.clear), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.value, isEmpty);
    });
  });

  group('BfSignatureField.toPng()', () {
    test('exports strokes to a Uint8List PNG image', () async {
      final controller = BfFieldController<List<List<Offset>>>(
        initialValue: [
          [const Offset(10, 10), const Offset(50, 50), const Offset(90, 10)],
        ],
      );

      // The toPng extension method should render strokes to a PNG.
      final png = await controller.toPng(
        width: 100,
        height: 100,
        strokeColor: const Color(0xFF000000),
        strokeWidth: 2.0,
      );

      expect(png, isA<Uint8List>());
      expect(png.length, greaterThan(0));

      // PNG files start with the magic bytes: 137 80 78 71 13 10 26 10
      expect(png[0], 137); // PNG signature
      expect(png[1], 80); // 'P'
      expect(png[2], 78); // 'N'
      expect(png[3], 71); // 'G'
    });

    test('returns empty PNG for null/empty strokes', () async {
      final controller = BfFieldController<List<List<Offset>>>();

      final png = await controller.toPng(width: 100, height: 100);

      // Should still return a valid PNG (blank canvas)
      expect(png, isA<Uint8List>());
      expect(png.length, greaterThan(0));
      expect(png[0], 137);
    });
  });

  group('BfSignatureField.toBase64()', () {
    test('exports strokes to a base64-encoded PNG string', () async {
      final controller = BfFieldController<List<List<Offset>>>(
        initialValue: [
          [const Offset(10, 10), const Offset(50, 50)],
        ],
      );

      final b64 = await controller.toBase64(width: 100, height: 100);

      expect(b64, isA<String>());
      expect(b64.isNotEmpty, isTrue);

      // Should be valid base64 that decodes to PNG bytes
      final decoded = base64Decode(b64);
      expect(decoded[0], 137); // PNG magic byte
      expect(decoded[1], 80);  // 'P'
    });

    test('returns base64 of blank canvas for empty strokes', () async {
      final controller = BfFieldController<List<List<Offset>>>();

      final b64 = await controller.toBase64(width: 50, height: 50);

      expect(b64, isA<String>());
      expect(b64.isNotEmpty, isTrue);

      final decoded = base64Decode(b64);
      expect(decoded[0], 137);
    });
  });
}
