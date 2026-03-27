import 'dart:developer' as developer;

import 'fk_log_category.dart';
import 'fk_log_level.dart';

/// A log entry produced by [FkLogger].
class FkLogEntry {
  /// Creates a log entry.
  const FkLogEntry({
    required this.level,
    required this.category,
    required this.message,
    this.field,
    this.detail,
    required this.timestamp,
  });

  /// Severity of this entry.
  final FkLogLevel level;

  /// Which subsystem produced this entry.
  final FkLogCategory category;

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
/// Return `true` to suppress the default output, or `false` to let FkLogger
/// also print it.
typedef FkLogHandler = bool Function(FkLogEntry entry);

/// Pretty, configurable logger for FlutterFormKit.
///
/// ## Quick start
///
/// ```dart
/// // Enable debug logging for everything
/// FkLogger.instance.level = FkLogLevel.debug;
///
/// // Only show validation and submission logs
/// FkLogger.instance.enabledCategories = {
///   FkLogCategory.validation,
///   FkLogCategory.submission,
/// };
///
/// // Silence all logging
/// FkLogger.instance.level = FkLogLevel.none;
/// ```
///
/// ## Custom handler
///
/// ```dart
/// FkLogger.instance.handler = (entry) {
///   myAnalytics.track('formkit_${entry.category.name}', {
///     'message': entry.message,
///     'field': entry.field,
///   });
///   return false; // also print to console
/// };
/// ```
class FkLogger {
  FkLogger._();

  /// The shared singleton instance.
  ///
  /// All FormKit internals use this instance. Configure it once at app startup.
  static final FkLogger instance = FkLogger._();

  // ---------------------------------------------------------------------------
  // Configuration
  // ---------------------------------------------------------------------------

  /// The minimum log level to emit. Defaults to [FkLogLevel.none] (silent).
  ///
  /// Set to [FkLogLevel.debug] or [FkLogLevel.verbose] during development.
  FkLogLevel level = FkLogLevel.none;

  /// Which categories to include. If `null`, all categories are included.
  ///
  /// ```dart
  /// FkLogger.instance.enabledCategories = {FkLogCategory.validation};
  /// ```
  Set<FkLogCategory>? enabledCategories;

  /// Optional custom handler. Called before the default console output.
  ///
  /// Return `true` from the handler to suppress the default output.
  FkLogHandler? handler;

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
    FkLogLevel entryLevel,
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) {
    if (!entryLevel.isEnabled(level)) return;
    if (enabledCategories != null && !enabledCategories!.contains(category)) {
      return;
    }

    final entry = FkLogEntry(
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
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(FkLogLevel.error, category, message, field: field, detail: detail);

  /// Log a warning.
  void warning(
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(FkLogLevel.warning, category, message, field: field, detail: detail);

  /// Log an informational message.
  void info(
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(FkLogLevel.info, category, message, field: field, detail: detail);

  /// Log a debug message.
  void debug(
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(FkLogLevel.debug, category, message, field: field, detail: detail);

  /// Log a verbose message.
  void verbose(
    FkLogCategory category,
    String message, {
    String? field,
    String? detail,
  }) =>
      log(FkLogLevel.verbose, category, message, field: field, detail: detail);

  // ---------------------------------------------------------------------------
  // Pretty printing
  // ---------------------------------------------------------------------------

  void _printEntry(FkLogEntry entry) {
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
      name: 'FkLogger',
      level: _dartLogLevel(entry.level),
    );
  }

  String _levelBadge(FkLogLevel lvl, bool c) {
    return switch (lvl) {
      FkLogLevel.error => c ? '$_red$_bold ERR $_reset' : ' ERR ',
      FkLogLevel.warning => c ? '$_yellow$_bold WRN $_reset' : ' WRN ',
      FkLogLevel.info => c ? '$_green$_bold INF $_reset' : ' INF ',
      FkLogLevel.debug => c ? '$_cyan DBG $_reset' : ' DBG ',
      FkLogLevel.verbose => c ? '$_gray VRB $_reset' : ' VRB ',
      FkLogLevel.none => '',
    };
  }

  String _categoryTag(FkLogCategory cat, bool c) {
    final label = switch (cat) {
      FkLogCategory.field => 'FIELD',
      FkLogCategory.validation => 'VALID',
      FkLogCategory.form => 'FORM ',
      FkLogCategory.submission => 'SUBMT',
      FkLogCategory.reset => 'RESET',
    };
    return c ? '$_magenta[$label]$_reset' : '[$label]';
  }

  int _dartLogLevel(FkLogLevel lvl) {
    return switch (lvl) {
      FkLogLevel.error => 1000,
      FkLogLevel.warning => 900,
      FkLogLevel.info => 800,
      FkLogLevel.debug => 500,
      FkLogLevel.verbose => 300,
      FkLogLevel.none => 0,
    };
  }
}
