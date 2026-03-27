import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'bf_error_display.dart';

/// Theme extension for customizing FlutterFormKit's appearance.
///
/// [BfFormTheme] integrates with Flutter's [ThemeExtension] system so that
/// all FormKit fields automatically pick up the configured styles.
///
/// Apply via [ThemeData.extensions]:
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       BfFormTheme(
///         fieldSpacing: 16.0,
///         sectionSpacing: 24.0,
///         errorDisplay: BfErrorDisplay.inline,
///         fieldBorderRadius: BorderRadius.circular(12),
///       ),
///     ],
///   ),
/// )
/// ```
class BfFormTheme extends ThemeExtension<BfFormTheme> {
  /// Creates a FormKit theme with the given styling properties.
  ///
  /// All parameters are optional and fall back to sensible defaults.
  const BfFormTheme({
    this.inputDecoration,
    this.labelStyle,
    this.errorStyle,
    this.hintStyle,
    this.fieldSpacing = 16.0,
    this.sectionSpacing = 24.0,
    this.errorDisplay = BfErrorDisplay.inline,
    this.fieldBorderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });

  /// Default [InputDecoration] applied to all FormKit fields.
  ///
  /// Individual fields may override specific properties while inheriting
  /// the rest from this base decoration.
  final InputDecoration? inputDecoration;

  /// Style for field labels.
  ///
  /// When `null`, fields fall back to the ambient [InputDecorationTheme]
  /// label style from the current [ThemeData].
  final TextStyle? labelStyle;

  /// Style for validation error text.
  ///
  /// When `null`, fields fall back to the ambient [InputDecorationTheme]
  /// error style from the current [ThemeData].
  final TextStyle? errorStyle;

  /// Style for hint text.
  ///
  /// When `null`, fields fall back to the ambient [InputDecorationTheme]
  /// hint style from the current [ThemeData].
  final TextStyle? hintStyle;

  /// Vertical spacing between fields (used by [BfFormSection]).
  ///
  /// Defaults to `16.0`.
  final double fieldSpacing;

  /// Vertical spacing between form sections.
  ///
  /// Defaults to `24.0`.
  final double sectionSpacing;

  /// How validation errors are displayed on fields.
  ///
  /// Defaults to [BfErrorDisplay.inline].
  final BfErrorDisplay errorDisplay;

  /// Border radius for field containers.
  ///
  /// When `null`, fields use the default border radius from the ambient
  /// [InputDecorationTheme].
  final BorderRadius? fieldBorderRadius;

  /// Duration for field animations (error appear/disappear, focus, etc).
  ///
  /// Defaults to `200ms`.
  final Duration animationDuration;

  /// Curve for field animations.
  ///
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// Retrieves the nearest [BfFormTheme] from the widget tree, or `null`.
  ///
  /// Returns `null` if no [BfFormTheme] has been registered in the
  /// current [ThemeData.extensions].
  static BfFormTheme? maybeOf(BuildContext context) {
    return Theme.of(context).extension<BfFormTheme>();
  }

  /// Retrieves the nearest [BfFormTheme], or returns a default instance.
  ///
  /// This is the primary way fields should access theme configuration.
  /// It guarantees a non-null return so callers never need null checks.
  static BfFormTheme of(BuildContext context) {
    return maybeOf(context) ?? const BfFormTheme();
  }

  @override
  BfFormTheme copyWith({
    InputDecoration? inputDecoration,
    TextStyle? labelStyle,
    TextStyle? errorStyle,
    TextStyle? hintStyle,
    double? fieldSpacing,
    double? sectionSpacing,
    BfErrorDisplay? errorDisplay,
    BorderRadius? fieldBorderRadius,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return BfFormTheme(
      inputDecoration: inputDecoration ?? this.inputDecoration,
      labelStyle: labelStyle ?? this.labelStyle,
      errorStyle: errorStyle ?? this.errorStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      fieldSpacing: fieldSpacing ?? this.fieldSpacing,
      sectionSpacing: sectionSpacing ?? this.sectionSpacing,
      errorDisplay: errorDisplay ?? this.errorDisplay,
      fieldBorderRadius: fieldBorderRadius ?? this.fieldBorderRadius,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  @override
  BfFormTheme lerp(BfFormTheme? other, double t) {
    if (other is! BfFormTheme) return this;

    return BfFormTheme(
      inputDecoration: t < 0.5 ? inputDecoration : other.inputDecoration,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      errorStyle: TextStyle.lerp(errorStyle, other.errorStyle, t),
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t),
      fieldSpacing: lerpDouble(fieldSpacing, other.fieldSpacing, t)!,
      sectionSpacing: lerpDouble(sectionSpacing, other.sectionSpacing, t)!,
      errorDisplay: t < 0.5 ? errorDisplay : other.errorDisplay,
      fieldBorderRadius:
          BorderRadius.lerp(fieldBorderRadius, other.fieldBorderRadius, t),
      animationDuration: Duration(
        milliseconds: lerpDouble(
          animationDuration.inMilliseconds.toDouble(),
          other.animationDuration.inMilliseconds.toDouble(),
          t,
        )!
            .round(),
      ),
      animationCurve: t < 0.5 ? animationCurve : other.animationCurve,
    );
  }
}
