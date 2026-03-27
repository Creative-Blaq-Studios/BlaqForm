import 'package:flutter/material.dart';

import '../state/fk_form_controller.dart';

/// Wraps its [child] in a [PopScope] that prevents navigation when the form
/// has unsaved changes ([FkFormController.isDirty]).
///
/// When the user attempts to pop while the form is dirty, an [AlertDialog] is
/// shown asking for confirmation. If they confirm, the navigator pops;
/// otherwise they stay on the page.
///
/// ```dart
/// FkDirtyGuard(
///   controller: formController,
///   child: MyFormBody(),
/// )
/// ```
class FkDirtyGuard extends StatelessWidget {
  /// Creates a dirty-guard wrapper.
  const FkDirtyGuard({
    required this.controller,
    required this.child,
    this.title = 'Unsaved Changes',
    this.message = 'You have unsaved changes. Are you sure you want to leave?',
    this.confirmText = 'Leave',
    this.cancelText = 'Stay',
    super.key,
  });

  /// The form controller whose [isDirty] state is monitored.
  final FkFormController controller;

  /// The widget subtree to display.
  final Widget child;

  /// Title of the confirmation dialog.
  final String title;

  /// Body message of the confirmation dialog.
  final String message;

  /// Label for the "confirm leave" button.
  final String confirmText;

  /// Label for the "cancel / stay" button.
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return PopScope(
          canPop: !controller.isDirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            final shouldLeave = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(cancelText),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(confirmText),
                  ),
                ],
              ),
            );

            if (shouldLeave == true && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: child,
        );
      },
    );
  }
}
