import 'package:flutter/widgets.dart';

/// Arranges form fields horizontally with configurable flex ratios.
///
/// Use this widget to place multiple fields side-by-side in a single row,
/// such as first name and last name fields.
///
/// ```dart
/// BfFormRow(
///   flexes: [2, 1],
///   children: [
///     BfTextField(name: 'street'),
///     BfTextField(name: 'zipCode'),
///   ],
/// )
/// ```
class BfFormRow extends StatelessWidget {
  /// Creates a horizontal row of form fields.
  ///
  /// If [flexes] is provided, its length must match the length of [children].
  /// When [flexes] is `null`, every child receives equal flex (`1`).
  const BfFormRow({
    super.key,
    required this.children,
    this.flexes,
    this.spacing = 16.0,
  }) : assert(
         flexes == null || flexes.length == children.length,
         'flexes length must match children length',
       );

  /// The widgets to arrange horizontally.
  final List<Widget> children;

  /// Flex ratios for each child.
  ///
  /// If `null`, all children get equal flex (`1`).
  /// When provided, its length must match [children] length.
  final List<int>? flexes;

  /// Horizontal spacing between children. Defaults to `16.0`.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rowChildren = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      if (i > 0) {
        rowChildren.add(SizedBox(width: spacing));
      }
      rowChildren.add(
        Expanded(flex: flexes != null ? flexes![i] : 1, child: children[i]),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rowChildren,
    );
  }
}
