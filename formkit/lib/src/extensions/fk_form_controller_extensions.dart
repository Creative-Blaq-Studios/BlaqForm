import '../state/fk_field_controller.dart';
import '../state/fk_form_controller.dart';

/// JSON serialization extensions on [FkFormController].
extension FkFormControllerJsonX on FkFormController {
  /// Serializes all field values to a JSON-compatible map.
  ///
  /// Values that are not natively JSON-serializable (e.g., [DateTime],
  /// [Offset]) are converted to strings. [DateTime] values use ISO 8601
  /// format; [List] values are recursed; everything else falls back to
  /// `.toString()`.
  Map<String, dynamic> toJson() {
    final map = toMap();
    return map.map((key, value) {
      return MapEntry(key, _toJsonValue(value));
    });
  }

  /// Populates form fields from a JSON map.
  ///
  /// Only sets values for fields that are currently registered in the form.
  /// Fields whose names do not appear in [json] are left unchanged.
  void fromJson(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      try {
        final controller = field<dynamic>(entry.key);
        controller.value = entry.value;
      } catch (_) {
        // Field not registered — skip silently.
      }
    }
  }

  /// Converts a single value to its JSON-safe representation.
  static dynamic _toJsonValue(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is List) {
      return value.map((e) => _toJsonValue(e)).toList();
    }
    return value.toString();
  }
}

/// Dirty tracking extensions on [FkFormController].
extension FkFormControllerDiffX on FkFormController {
  /// Returns a map containing only the fields whose values have changed
  /// from their initial values (i.e., fields where [FkFieldController.isDirty]
  /// is `true`).
  ///
  /// This is useful for PATCH-style updates where you only want to send
  /// modified values to the server.
  Map<String, dynamic> dirtyValues() {
    final result = <String, dynamic>{};
    final all = toMap();
    for (final entry in all.entries) {
      try {
        final controller = field<dynamic>(entry.key);
        if (controller.isDirty) {
          result[entry.key] = entry.value;
        }
      } catch (_) {
        // Should not happen since we iterate toMap() keys, but guard anyway.
      }
    }
    return result;
  }
}
