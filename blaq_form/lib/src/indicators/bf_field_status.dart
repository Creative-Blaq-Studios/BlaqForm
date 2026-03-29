import 'package:flutter/material.dart';

import '../state/bf_field_controller.dart';

/// Displays an icon reflecting the current validation status of a single field.
///
/// * **Validating** — [CircularProgressIndicator]
/// * **Valid + touched** — [Icons.check_circle] (green)
/// * **Error + touched** — [Icons.error] (red)
/// * **Untouched** — empty [SizedBox]
///
/// ```dart
/// BfFieldStatus(controller: emailController)
/// ```
class BfFieldStatus extends StatelessWidget {
  /// Creates a field-status indicator.
  const BfFieldStatus({
    required this.controller,
    this.size = 20.0,
    this.validIcon,
    this.errorIcon,
    this.validColor,
    this.errorColor,
    super.key,
  });

  /// The field controller to observe.
  final BfFieldController controller;

  /// The size of the icon / progress indicator in logical pixels.
  final double size;

  /// Override for the "valid" icon. Defaults to [Icons.check_circle].
  final IconData? validIcon;

  /// Override for the "error" icon. Defaults to [Icons.error].
  final IconData? errorIcon;

  /// Override for the valid-icon colour. Defaults to [Colors.green].
  final Color? validColor;

  /// Override for the error-icon colour. Defaults to the theme error colour.
  final Color? errorColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isValidating) {
          return SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (!controller.isTouched) {
          return SizedBox(width: size, height: size);
        }

        if (controller.error != null) {
          return Icon(
            errorIcon ?? Icons.error,
            size: size,
            color: errorColor ?? Theme.of(context).colorScheme.error,
          );
        }

        // Touched and valid
        return Icon(
          validIcon ?? Icons.check_circle,
          size: size,
          color: validColor ?? Colors.green,
        );
      },
    );
  }
}
