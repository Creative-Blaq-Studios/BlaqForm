import 'dart:developer' as developer;

import 'bf_log_category.dart';
import 'bf_log_level.dart';

/// A log entry produced by [BfLogger].
class BfLogEntry {
  /// Creates a log entry.
  const BfLogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.field,
    this.detail,
    required this.timestamp,
  });

  /// Severity of this entry.
  final BfLogLevel level;

  /// Which subsystem produced this entry.
  final BfLogCategory category;

  /// Human-readable summary.
  final String message;

  /// The field name this entry relates to, if any.
  final String? field;

  /// Optional extra detail (e.g. the validation error message, the new value).
  final String? detail;

  /// When this entry was created.
  final DateTime timestamp;

  @override
  String toString() {
    final buf = StringBuffer()
      ..write('[${level.name.toUpperCase()}]')
      ..write(' [${category.name}]');
    if (field != null) buf.write(' ($field)');
    buf.write(' $message');
    if (detail != null) buf.write(' — $detail');
    return buf.toString();
  }
}

/// Callback signature for custom log handlers.
///
/// Return `true` to suppress the default output, or `false` to let BfLogger
/// also print it.
typedef BfLogHandler = bool Function(BfLogEntry entry);

/// Pretty, configurable logger for BlaqForm.
///
/// ## Quick start
///
/// ```dart
/// // Enable debug logging for everything
/// BfLogger.instance.level = BfLogLevel.debug;
///
/// // Only show validation and submission logs
/// BfLogger.instance.enabledCategories = {
///   BfLogCategory.validation,
///   BfLogCategory.submission,
/// };
///
/// // Silence all logging
/// BfLogger.instance.level = BfLogLevel.none;
/// ```
///
/// ## Custom handler
///
/// ```dart
/// BfLogger.instance.handler = (entry) {
///   myAnalytics.track('blaq_form_${entry.category.name}', {
///     'message': entry.message,
///     'field': entry.field,
///   });
///   return false; // also print to console
/// };
/// ```
class BfLogger {
  BfLogger._();

  /// The shared singleton instance.
  ///
  /// All BlaqForm internals use this instance. Configure it once at app startup.
  static final BfLogger instance = BfLogger._();

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// The minimum log level to emit. Defaults to [BfLogLevel.none] (silent).
  ///
  /// Set to [BfLogLevel.debug] or [BfLogLevel.verbose] during development.
  BfLogLevel level = BfLogLevel.none;

  /// Which categories to include. If `null`, all categories are included.
  ///
  /// ```dart
  /// BfLogger.instance.enabledCategories = {BfLogCategory.validation};
  /// ```
  Set<BfLogCategory>? enabledCategories;

  /// Optional custom handler. Called before the default console output.
  ///
  /// Return `true` from the handler to suppress the default output.
  BfLogHandler? handler;

  /// Whether to use ANSI color codes in console output.
  ///
  /// Defaults to `true`. Set to `false` for environments that don't support
  /// ANSI (e.g. some CI loggers, Flutter DevTools console).
  bool useColors = true;

  // ---------------------------------------------------------------------------
  // ANSI color codes
  // ---------------------------------------------------------------------------

  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _cyan = '\x1B[36m';
  static const _gray = '\x1B[90m';
  static const _magenta = '\x1B[35m';
  static const _bold = '\x1B[1m';

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Logs a message if [level] and [category] checks pass.
  void log(
    BfLogLevel entryLevel,
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) {
    if (!entryLevel.isEnabled(level)) return;
    if (enabledCategories != null && !enabledCategories!.contains(category)) {
      return;
    }

    final entry = BfLogEntry(
      level: entryLevel,
      category: category,
      message: message,
      field: field,
      detail: detail,
      timestamp: DateTime.now(),
    );

    // Custom handler gets first shot.
    if (handler != null && handler!(entry)) return;

    // Default console output.
    _printEntry(entry);
  }

  // Convenience methods -------------------------------------------------------

  /// Log an error.
  void error(
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(BfLogLevel.error, category, message, field: field, detail: detail);

  /// Log a warning.
  void warning(
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(BfLogLevel.warning, category, message, field: field, detail: detail);

  /// Log an informational message.
  void info(
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(BfLogLevel.info, category, message, field: field, detail: detail);

  /// Log a debug message.
  void debug(
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(BfLogLevel.debug, category, message, field: field, detail: detail);

  /// Log a verbose message.
  void verbose(
    BfLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(BfLogLevel.verbose, category, message, field: field, detail: detail);

  // ---------------------------------------------------------------------------
  // Pretty printing
  // ---------------------------------------------------------------------------

  void _printEntry(BfLogEntry entry) {
    final c = useColors;
    final buf = StringBuffer();

    // Timestamp
    final ts = entry.timestamp;
    final timeStr =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}.${ts.millisecond.toString().padLeft(3, '0')}';
    buf.write(c ? '$_gray$timeStr$_reset ' : '$timeStr ');

    // Level badge
    buf.write(_levelBadge(entry.level, c));
    buf.write(' ');

    // Category tag
    buf.write(_categoryTag(entry.category, c));
    buf.write(' ');

    // Field name
    if (entry.field != null) {
      buf.write(c ? '$_bold${entry.field}$_reset ' : '${entry.field} ');
    }

    // Arrow + message
    buf.write(c ? '$_gray→$_reset ' : '→ ');
    buf.write(entry.message);

    // Detail
    if (entry.detail != null) {
      buf.write(c ? ' $_gray— ${entry.detail}$_reset' : ' — ${entry.detail}');
    }

    developer.log(
      buf.toString(),
      name: 'BfLogger',
      level: _dartLogLevel(entry.level),
    );
  }

  String _levelBadge(BfLogLevel lvl, bool c) {
    return switch (lvl) {
      BfLogLevel.error => c ? '$_red$_bold ERR $_reset' : ' ERR ',
      BfLogLevel.warning => c ? '$_yellow$_bold WRN $_reset' : ' WRN ',
      BfLogLevel.info => c ? '$_green$_bold INF $_reset' : ' INF ',
      BfLogLevel.debug => c ? '$_cyan DBG $_reset' : ' DBG ',
      BfLogLevel.verbose => c ? '$_gray VRB $_reset' : ' VRB ',
      BfLogLevel.none => '',
    };
  }

  String _categoryTag(BfLogCategory cat, bool c) {
    final label = switch (cat) {
      BfLogCategory.field => 'FIELD',
      BfLogCategory.validation => 'VALID',
      BfLogCategory.form => 'FORM ',
      BfLogCategory.submission => 'SUBMT',
      BfLogCategory.reset => 'RESET',
    };
    return c ? '$_magenta[$label]$_reset' : '[$label]';
  }

  int _dartLogLevel(BfLogLevel lvl) {
    return switch (lvl) {
      BfLogLevel.error => 1000,
      BfLogLevel.warning => 900,
      BfLogLevel.info => 800,
      BfLogLevel.debug => 500,
      BfLogLevel.verbose => 300,
      BfLogLevel.none => 0,
    };
  }
}
