/// How validation errors are displayed on fields.
///
/// Used by [FkFormTheme.errorDisplay] to control the presentation of
/// validation messages across all fields in a form.
enum FkErrorDisplay {
  /// Error text shown inline below the field (default Material behavior).
  inline,

  /// Error shown as a tooltip on hover/focus.
  tooltip,

  /// Error shown as a floating label above the field.
  floating,
}
