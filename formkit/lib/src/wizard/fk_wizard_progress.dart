import 'package:flutter/material.dart';

import 'fk_wizard_controller.dart';

/// A visual progress indicator for an [FkWizardController].
///
/// Displays step circles with numbers or checkmarks, connecting lines,
/// and step titles. Uses [ListenableBuilder] to rebuild automatically
/// when the wizard controller's active step changes.
///
/// - **Active step**: filled circle with primary color
/// - **Completed steps** (index < currentStep): primary color with checkmark
/// - **Future steps**: outlined circle
///
/// ```dart
/// FkWizardProgress(controller: wizardController)
/// ```
class FkWizardProgress extends StatelessWidget {
  /// Creates a wizard progress indicator.
  const FkWizardProgress({
    super.key,
    required this.controller,
    this.activeColor,
    this.inactiveColor,
    this.lineThickness = 2.0,
    this.circleSize = 32.0,
  });

  /// The wizard controller to observe.
  final FkWizardController controller;

  /// The color for active and completed steps. Defaults to the theme's
  /// primary color.
  final Color? activeColor;

  /// The color for future steps. Defaults to grey.
  final Color? inactiveColor;

  /// Thickness of the connecting lines between circles.
  final double lineThickness;

  /// Diameter of each step circle.
  final double circleSize;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final theme = Theme.of(context);
        final primary = activeColor ?? theme.colorScheme.primary;
        final inactive = inactiveColor ?? Colors.grey.shade400;

        return Row(
          children: [
            for (int i = 0; i < controller.stepCount; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: lineThickness,
                    color: i <= controller.currentStep ? primary : inactive,
                  ),
                ),
              _StepCircle(
                index: i,
                currentStep: controller.currentStep,
                title: controller.steps[i].title,
                primary: primary,
                inactive: inactive,
                size: circleSize,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.index,
    required this.currentStep,
    required this.title,
    required this.primary,
    required this.inactive,
    required this.size,
  });

  final int index;
  final int currentStep;
  final String title;
  final Color primary;
  final Color inactive;
  final double size;

  bool get _isCompleted => index < currentStep;
  bool get _isActive => index == currentStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (_isActive || _isCompleted) ? primary : Colors.transparent,
            border: Border.all(
              color: (_isActive || _isCompleted) ? primary : inactive,
              width: 2,
            ),
          ),
          child: Center(
            child: _isCompleted
                ? Icon(Icons.check, size: size * 0.5, color: Colors.white)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.w600,
                      color: _isActive ? Colors.white : inactive,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: (_isActive || _isCompleted) ? primary : inactive,
            fontWeight: _isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
