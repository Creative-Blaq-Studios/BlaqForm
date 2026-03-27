/// Controls when fields in an [FkForm] are validated automatically.
enum FkAutovalidateMode {
  /// No automatic validation. Fields only validate on explicit calls.
  disabled,

  /// Validate after user interaction (field becomes touched).
  onUserInteraction,

  /// Validate continuously as values change.
  always,

  /// Validate only when the form is submitted.
  onSubmit,
}
