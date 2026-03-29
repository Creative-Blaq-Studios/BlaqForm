import '../state/bf_form_controller.dart';

/// Abstract interface for persisting form state.
///
/// Implement this to back form data with any storage mechanism
/// (SharedPreferences, Hive, SQLite, secure storage, etc.).
///
/// ```dart
/// final persistence = BfMemoryPersistence();
/// await persistence.saveForm(myFormController);
/// await persistence.restoreForm(myFormController);
/// ```
abstract class BfFormPersistence {
  /// Persists [values] to the underlying storage.
  Future<void> save(Map<String, dynamic> values);

  /// Retrieves the previously persisted values.
  ///
  /// Returns `null` if nothing has been saved yet.
  Future<Map<String, dynamic>?> load();

  /// Removes all persisted values from the underlying storage.
  Future<void> clear();

  /// Convenience: serializes all field values from [controller] via
  /// [BfFormController.toMap] and delegates to [save].
  Future<void> saveForm(BfFormController controller) => save(controller.toMap());

  /// Convenience: loads persisted values and populates registered fields on
  /// [controller].
  ///
  /// Silently skips any key that does not correspond to a registered field.
  Future<void> restoreForm(BfFormController controller) async {
    final values = await load();
    if (values == null) return;
    for (final entry in values.entries) {
      try {
        final field = controller.field<dynamic>(entry.key);
        field.value = entry.value;
      } catch (_) {
        // skip unregistered fields
      }
    }
  }
}
