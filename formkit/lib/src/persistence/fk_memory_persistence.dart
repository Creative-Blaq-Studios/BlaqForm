import 'fk_form_persistence.dart';

/// An in-memory implementation of [FkFormPersistence].
///
/// Data is stored in a plain Dart [Map] and is lost when the object is
/// garbage-collected. Useful for testing and for short-lived draft state
/// that does not need to survive app restarts.
///
/// ```dart
/// final persistence = FkMemoryPersistence();
/// await persistence.save({'email': 'user@example.com'});
/// final values = await persistence.load(); // {'email': 'user@example.com'}
/// await persistence.clear();
/// await persistence.load(); // null
/// ```
class FkMemoryPersistence extends FkFormPersistence {
  Map<String, dynamic>? _store;

  /// Stores a copy of [values] in memory, replacing any previous state.
  @override
  Future<void> save(Map<String, dynamic> values) async {
    _store = Map<String, dynamic>.of(values);
  }

  /// Returns a copy of the stored values, or `null` if [save] has not been
  /// called (or [clear] was called after the last [save]).
  @override
  Future<Map<String, dynamic>?> load() async {
    if (_store == null) return null;
    return Map<String, dynamic>.of(_store!);
  }

  /// Discards the stored values.
  @override
  Future<void> clear() async {
    _store = null;
  }
}
