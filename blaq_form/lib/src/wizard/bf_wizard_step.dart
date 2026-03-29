import 'package:flutter/widgets.dart';

/// An immutable description of a single step in an [BfWizard].
///
/// Each step declares a [title], the [fieldNames] that belong to it,
/// and optional [subtitle] and [icon] for display purposes.
///
/// ```dart
/// BfWizardStep(
///   title: 'Personal Info',
///   fieldNames: ['name', 'email'],
///   subtitle: 'Enter your details',
///   icon: Icons.person,
/// )
/// ```
class BfWizardStep {
  /// Creates a wizard step.
  ///
  /// [title] is the human-readable label shown in progress indicators.
  /// [fieldNames] lists the field keys that belong to this step.
  const BfWizardStep({
    required this.title,
    required this.fieldNames,
    this.subtitle,
    this.icon,
  });

  /// The human-readable title for this step.
  final String title;

  /// The field names (keys in the `fields` map) that belong to this step.
  final List<String> fieldNames;

  /// An optional subtitle for additional context.
  final String? subtitle;

  /// An optional icon displayed alongside the step title.
  final IconData? icon;
}
