import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formkit/formkit.dart';

void main() {
  group('FkFormTheme', () {
    test('copyWith() returns new instance with overridden values', () {
      // Given: a default theme
      const theme = FkFormTheme();

      // When: we copy with overridden values
      final updated = theme.copyWith(
        fieldSpacing: 32.0,
        sectionSpacing: 48.0,
        errorDisplay: FkErrorDisplay.tooltip,
      );

      // Then: the overridden values are applied
      expect(updated.fieldSpacing, equals(32.0));
      expect(updated.sectionSpacing, equals(48.0));
      expect(updated.errorDisplay, equals(FkErrorDisplay.tooltip));
    });

    test('copyWith() preserves values not overridden', () {
      // Given: a theme with custom values
      const theme = FkFormTheme(
        fieldSpacing: 20.0,
        sectionSpacing: 30.0,
        errorDisplay: FkErrorDisplay.floating,
      );

      // When: we copy with only fieldSpacing overridden
      final updated = theme.copyWith(fieldSpacing: 40.0);

      // Then: non-overridden values are preserved
      expect(updated.fieldSpacing, equals(40.0));
      expect(updated.sectionSpacing, equals(30.0));
      expect(updated.errorDisplay, equals(FkErrorDisplay.floating));
    });

    test('lerp() interpolates numeric values (fieldSpacing, sectionSpacing)',
        () {
      // Given: two themes with different numeric values
      const themeA = FkFormTheme(fieldSpacing: 10.0, sectionSpacing: 20.0);
      const themeB = FkFormTheme(fieldSpacing: 30.0, sectionSpacing: 40.0);

      // When: we lerp at t=0.5
      final result = themeA.lerp(themeB, 0.5);

      // Then: numeric values are interpolated
      expect(result.fieldSpacing, equals(20.0));
      expect(result.sectionSpacing, equals(30.0));
    });

    test('lerp() uses t < 0.5 threshold for enums', () {
      // Given: two themes with different errorDisplay enums
      const themeA = FkFormTheme(errorDisplay: FkErrorDisplay.inline);
      const themeB = FkFormTheme(errorDisplay: FkErrorDisplay.tooltip);

      // When: we lerp at t=0.3 (< 0.5)
      final resultA = themeA.lerp(themeB, 0.3);

      // Then: the first theme's enum is used
      expect(resultA.errorDisplay, equals(FkErrorDisplay.inline));

      // When: we lerp at t=0.7 (>= 0.5)
      final resultB = themeA.lerp(themeB, 0.7);

      // Then: the second theme's enum is used
      expect(resultB.errorDisplay, equals(FkErrorDisplay.tooltip));
    });

    testWidgets('of() returns default instance when no theme in tree',
        (tester) async {
      // Given: a widget tree with no FkFormTheme in ThemeData
      late FkFormTheme capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTheme = FkFormTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: a default FkFormTheme is returned
      expect(capturedTheme.fieldSpacing, equals(16.0));
      expect(capturedTheme.sectionSpacing, equals(24.0));
      expect(capturedTheme.errorDisplay, equals(FkErrorDisplay.inline));
    });

    testWidgets('maybeOf() returns null when no theme in tree', (tester) async {
      // Given: a widget tree with no FkFormTheme in ThemeData
      FkFormTheme? capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedTheme = FkFormTheme.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: null is returned
      expect(capturedTheme, isNull);
    });

    testWidgets('of() returns theme from ThemeData.extensions', (tester) async {
      // Given: a widget tree with a custom FkFormTheme in ThemeData
      late FkFormTheme capturedTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const [
              FkFormTheme(
                fieldSpacing: 42.0,
                sectionSpacing: 99.0,
                errorDisplay: FkErrorDisplay.floating,
              ),
            ],
          ),
          home: Builder(
            builder: (context) {
              capturedTheme = FkFormTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      // Then: the custom theme is returned
      expect(capturedTheme.fieldSpacing, equals(42.0));
      expect(capturedTheme.sectionSpacing, equals(99.0));
      expect(capturedTheme.errorDisplay, equals(FkErrorDisplay.floating));
    });
  });
}
