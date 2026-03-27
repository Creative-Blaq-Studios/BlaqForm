/// Provides context for cross-field validation.
///
/// [FkValidationContext] allows validators to access sibling field values
/// without creating a direct dependency on the form controller. This is
/// achieved through a generic [fieldValueGetter] callback.
///
/// ```dart
/// final context = FkValidationContext(
///   fieldValueGetter: <T>(name) => formController.field<T>(name).value,
/// );
///
/// // Inside a validator:
/// final password = context.sibling<String>('password');
/// ```
class FkValidationContext {
  /// A callback that retrieves a sibling field's value by name.
  ///
  /// Uses a generic type parameter to return the value with proper typing,
  /// avoiding circular dependencies with controller classes.
  final T? Function<T>(String name) fieldValueGetter;

  /// Creates a validation context with the given [fieldValueGetter].
  const FkValidationContext({required this.fieldValueGetter});

  /// Retrieves the value of a sibling field by [name].
  ///
  /// Returns `null` if the field does not exist or has no value.
  ///
  /// ```dart
  /// final email = context.sibling<String>('email');
  /// final age = context.sibling<int>('age');
  /// ```
  T? sibling<T>(String name) => fieldValueGetter<T>(name);
}
