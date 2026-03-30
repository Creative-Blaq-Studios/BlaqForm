import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blaq_form/blaq_form.dart';

void main() {
  group('BfFormTheme', () {
    test('copyWith() returns new instance with overridden values', () {
      // Given: a default theme
      const theme = BfFormTheme();

      // When: we copy with overridden values
      final updated = theme.copyWith(
        fieldSpacing: 32.0,
        sectionSpacing: 48.0,
        errorDisplay: BfErrorDisplay.tooltip,
      );

      // Then: the overridden values are applied
      expect(updated.fieldSpacing, equals(32.0));
      expect(updated.sectionSpacing, equals(48.0));
      expect(updated.errorDisplay, equals(BfErrorDisplay.tooltip));
    });

    test('copyWith() preserves values not overridden', () {
      // Given: a theme with custom values
      const theme = BfFormTheme(
        fieldSpacing: 20.0,
        sectionSpacing: 30.0,
        errorDisplay: BfErrorDisplay.floating,
      );

      // When: we copy with only fieldSpacing overridden
      final updated = theme.copyWith(fieldSpacing: 40.0);

      // Then: non-overridden values are preserved
      expect(updated.fieldSpacing, equals(40.0));
      expect(updated.sectionSpacing, equals(30.0));
      expect(updated.errorDisplay, equals(BfErrorDisplay.floating));
    });

    test(
      'lerp() interpolates numeric values (fieldSpacing, sectionSpacing)',
      () {
        // Given: two themes with different numeric values
        const themeA = BfFormTheme(fieldSpacing: 10.0, sectionSpacing: 20.0);
        const themeB = BfFormTheme(fieldSpacing: 30.0, sectionSpacing: 40.0);

        // When: we lerp at t=0.5
        final result = themeA.lerp(themeB, 0.5);

        // Then: numeric values are interpolated
        expect(result.fieldSpacing, equals(20.0));
        expect(result.sectionSpacing, equals(30.0));
      },
    );

    test('lerp() uses t < 0.5 threshold for enums', () {
      // Given: two themes with different errorDisplay enums
      const themeA = BfFormTheme(errorDisplay: BfErrorDisplay.inline);
      const themeB = BfFormTheme(errorDisplay: BfErrorDisplay.tooltip);

      // When: we lerp at t=0.3 (< 0.5)
      final resultA = themeA.lerp(themeB, 0.3);

      // Then: the first theme's enum is used
      expect(resultA.errorDisplay, equals(BfErrorDisplay.inline));

      // When: we lerp at t=0.7 (>= 0.5)
      final resultB = themeA.lerp(themeB, 0.7);

      // Then: the second theme's enum is used
      expect(resultB.errorDisplay, equals(BfErrorDisplay.tooltip));
    });

    testWidgets('of() returns default instance when no theme in tree', (
      tester,
    ) async {
      // Given: a widget tree with no BfFormTheme in ThemeData
      late BfFormTheme capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTheme = BfFormTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: a default BfFormTheme is returned
      expect(capturedTheme.fieldSpacing, equals(16.0));
      expect(capturedTheme.sectionSpacing, equals(24.0));
      expect(capturedTheme.errorDisplay, equals(BfErrorDisplay.inline));
    });

    testWidgets('maybeOf() returns null when no theme in tree', (tester) async {
      // Given: a widget tree with no BfFormTheme in ThemeData
      BfFormTheme? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTheme = BfFormTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: null is returned
      expect(capturedTheme, isNull);
    });

    testWidgets('of() returns theme from ThemeData.extensions', (tester) async {
      // Given: a widget tree with a custom BfFormTheme in ThemeData
      late BfFormTheme capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              BfFormTheme(
                fieldSpacing: 42.0,
                sectionSpacing: 99.0,
                errorDisplay: BfErrorDisplay.floating,
              ),
            ],
          ),
          home: Builder(
            builder: (context) {
              capturedTheme = BfFormTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: the custom theme is returned
      expect(capturedTheme.fieldSpacing, equals(42.0));
      expect(capturedTheme.sectionSpacing, equals(99.0));
      expect(capturedTheme.errorDisplay, equals(BfErrorDisplay.floating));
    });
  });
}
