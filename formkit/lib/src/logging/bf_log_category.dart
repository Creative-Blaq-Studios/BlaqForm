/// Categories of log messages emitted by FormKit.
///
/// Use these to filter logging output to only the subsystems you care about.
///
/// ```dart
/// BfLogger.instance.enabledCategories = {
///   BfLogCategory.validation,
///   BfLogCategory.submission,
/// };
/// ```
enum BfLogCategory {
  /// Field value changes, dirty/touched state transitions.
  field,

  /// Sync and async validator runs, results, composition.
  validation,

  /// Field registration, unregistration, form aggregate state.
  form,

  /// Submit lifecycle: start, validation gate, success/failure.
  submission,

  /// Field reset, form reset, error clearing.
  reset,
}
