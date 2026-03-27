/// Severity levels for [FkLogger] output.
///
/// Levels are ordered from most severe to least. Setting the logger to a
/// given level enables that level and all levels above it.
enum FkLogLevel implements Comparable<FkLogLevel> {
  /// No logging output.
  none(0),

  /// Errors that prevent normal operation (e.g. validation crash).
  error(1),

  /// Potentially harmful situations (e.g. field registered twice).
  warning(2),

  /// Informational messages about key lifecycle events
  /// (e.g. form submitted, field registered).
  info(3),

  /// Fine-grained messages useful during development
  /// (e.g. value changed, sync validation ran).
  debug(4),

  /// Very detailed output including async token tracking and debounce
  /// scheduling.
  verbose(5);

  const FkLogLevel(this.value);

  /// Numeric priority — higher means more verbose.
  final int value;

  @override
  int compareTo(FkLogLevel other) => value.compareTo(other.value);

  /// Returns `true` if this level should be emitted at [threshold].
  bool isEnabled(FkLogLevel threshold) => value <= threshold.value;
}
