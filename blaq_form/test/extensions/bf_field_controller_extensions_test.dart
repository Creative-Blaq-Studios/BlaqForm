import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFieldControllerStringX', () {
    test('trimmed returns trimmed value', () {
      // Given: a string controller with whitespace-padded value
      final controller = BfFieldController<String>(initialValue: '  hello  ');

      // When: we access trimmed
      final result = controller.trimmed;

      // Then: the value is trimmed
      expect(result, equals('hello'));

      controller.dispose();
    });

    test('trimmed returns null when value is null', () {
      // Given: a string controller with null value
      final controller = BfFieldController<String>();

      // When: we access trimmed
      final result = controller.trimmed;

      // Then: it returns null
      expect(result, isNull);

      controller.dispose();
    });

    test('wordCount returns correct count for multi-word string', () {
      // Given: a string controller with a multi-word value
      final controller =
          BfFieldController<String>(initialValue: 'hello world foo');

      // When: we access wordCount
      final result = controller.wordCount;

      // Then: the word count is 3
      expect(result, equals(3));

      controller.dispose();
    });

    test('wordCount returns 0 for null value', () {
      // Given: a string controller with null value
      final controller = BfFieldController<String>();

      // When: we access wordCount
      final result = controller.wordCount;

      // Then: it returns 0
      expect(result, equals(0));

      controller.dispose();
    });

    test('wordCount returns 0 for empty string', () {
      // Given: a string controller with empty value
      final controller = BfFieldController<String>(initialValue: '');

      // When: we access wordCount
      final result = controller.wordCount;

      // Then: it returns 0
      expect(result, equals(0));

      controller.dispose();
    });

    test('wordCount handles multiple spaces correctly', () {
      // Given: a string controller with multiple spaces between words
      final controller =
          BfFieldController<String>(initialValue: '  one   two   three  ');

      // When: we access wordCount
      final result = controller.wordCount;

      // Then: it correctly counts 3 words (splits on whitespace regex)
      expect(result, equals(3));

      controller.dispose();
    });
  });

  group('BfFieldControllerWidgetX', () {
    testWidgets('watch() returns a widget that rebuilds on controller change',
        (tester) async {
      // Given: a string controller and a widget built via watch()
      final controller = BfFieldController<String>(initialValue: 'initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: controller.watch(
              (c) => Text(c.value ?? '', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );

      // Then: the initial value is displayed
      expect(find.text('initial'), findsOneWidget);

      // When: the controller value changes
      controller.value = 'updated';
      await tester.pump();

      // Then: the widget rebuilds with the new value
      expect(find.text('updated'), findsOneWidget);
      expect(find.text('initial'), findsNothing);

      controller.dispose();
    });
  });
}
