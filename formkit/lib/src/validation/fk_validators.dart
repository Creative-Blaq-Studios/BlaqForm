import 'fk_async_validator.dart';
import 'fk_validation_context.dart';
import 'fk_validation_result.dart';
import 'fk_validator.dart';

/// The `Fk` namespace provides static factory methods for all prebuilt
/// validators in FlutterFormKit.
///
/// All validators return user-friendly default messages and support
/// an optional custom [message] override.
///
/// ```dart
/// final controller = FkFieldController<String>(
///   validators: [
///     Fk.required(),
///     Fk.email(),
///     Fk.minLength(8),
///   ],
/// );
/// ```
abstract class Fk {
  // ---------------------------------------------------------------------------
  // String validators
  // ---------------------------------------------------------------------------

  /// Validates that the value is not null and not empty.
  ///
  /// Works on any type. For [String] values, also checks that the string
  /// is not empty after trimming.
  ///
  /// ```dart
  /// Fk.required() // "This field is required"
  /// Fk.required(message: 'Please enter your name')
  /// ```
  static FkValidator<T> required<T>({String? message}) =>
      _RequiredValidator<T>(message);

  /// Validates that the string is a valid email address.
  ///
  /// Uses a regex pattern that covers common email formats.
  ///
  /// ```dart
  /// Fk.email() // "Invalid email address"
  /// ```
  static FkValidator<String> email({String? message}) =>
      _EmailValidator(message);

  /// Validates that the string has at least [min] characters.
  ///
  /// ```dart
  /// Fk.minLength(8) // "Must be at least 8 characters"
  /// ```
  static FkValidator<String> minLength(int min, {String? message}) =>
      _MinLengthValidator(min, message);

  /// Validates that the string has at most [max] characters.
  ///
  /// ```dart
  /// Fk.maxLength(100) // "Must be at most 100 characters"
  /// ```
  static FkValidator<String> maxLength(int max, {String? message}) =>
      _MaxLengthValidator(max, message);

  /// Validates that the string matches the given [regex] pattern.
  ///
  /// ```dart
  /// Fk.pattern(RegExp(r'^[A-Z]'), message: 'Must start with uppercase')
  /// ```
  static FkValidator<String> pattern(RegExp regex, {String? message}) =>
      _PatternValidator(regex, message);

  /// Validates that the string is a valid URL.
  ///
  /// Accepts `http`, `https`, and `ftp` schemes.
  ///
  /// ```dart
  /// Fk.url() // "Invalid URL"
  /// ```
  static FkValidator<String> url({String? message}) => _UrlValidator(message);

  /// Validates that the string is a valid phone number.
  ///
  /// Accepts digits, spaces, dashes, parentheses, and an optional
  /// leading `+`. Requires at least 7 digits.
  ///
  /// ```dart
  /// Fk.phone() // "Invalid phone number"
  /// ```
  static FkValidator<String> phone({String? message}) =>
      _PhoneValidator(message);

  /// Validates that the string is a valid credit card number.
  ///
  /// Uses the Luhn algorithm to verify the card number.
  ///
  /// ```dart
  /// Fk.creditCard() // "Invalid credit card number"
  /// ```
  static FkValidator<String> creditCard({String? message}) =>
      _CreditCardValidator(message);

  // ---------------------------------------------------------------------------
  // Numeric validators
  // ---------------------------------------------------------------------------

  /// Validates that the numeric value is at least [min].
  ///
  /// ```dart
  /// Fk.min(0) // "Must be at least 0"
  /// ```
  static FkValidator<num> min(num min, {String? message}) =>
      _MinValidator(min, message);

  /// Validates that the numeric value is at most [max].
  ///
  /// ```dart
  /// Fk.max(100) // "Must be at most 100"
  /// ```
  static FkValidator<num> max(num max, {String? message}) =>
      _MaxValidator(max, message);

  /// Validates that the numeric value is between [min] and [max] (inclusive).
  ///
  /// ```dart
  /// Fk.between(1, 10) // "Must be between 1 and 10"
  /// ```
  static FkValidator<num> between(num min, num max, {String? message}) =>
      _BetweenValidator(min, max, message);

  // ---------------------------------------------------------------------------
  // Date validators
  // ---------------------------------------------------------------------------

  /// Validates that the date is after [date].
  ///
  /// ```dart
  /// Fk.after(DateTime(2024, 1, 1)) // "Must be after 2024-01-01"
  /// ```
  static FkValidator<DateTime> after(DateTime date, {String? message}) =>
      _AfterDateValidator(date, message);

  /// Validates that the date is before [date].
  ///
  /// ```dart
  /// Fk.before(DateTime(2030, 1, 1)) // "Must be before 2030-01-01"
  /// ```
  static FkValidator<DateTime> before(DateTime date, {String? message}) =>
      _BeforeDateValidator(date, message);

  /// Validates that the date represents an age of at least [minimumAge] years.
  ///
  /// Compares the date against the current date to determine age.
  ///
  /// ```dart
  /// Fk.age(18) // "Must be at least 18 years old"
  /// ```
  static FkValidator<DateTime> age(int minimumAge, {String? message}) =>
      _AgeValidator(minimumAge, message);

  // ---------------------------------------------------------------------------
  // Generic validators
  // ---------------------------------------------------------------------------

  /// Validates that the value equals [expected].
  ///
  /// ```dart
  /// Fk.equals('yes') // "Value must equal yes"
  /// ```
  static FkValidator<T> equals<T>(T expected, {String? message}) =>
      _EqualsValidator<T>(expected, message);

  /// Creates a validator from a custom callback function.
  ///
  /// Return `null` from [fn] if the value is valid, or an
  /// [FkValidationResult] if invalid.
  ///
  /// ```dart
  /// Fk.custom<String>((value) {
  ///   if (value?.contains('bad') ?? false) {
  ///     return FkValidationResult('Contains forbidden word');
  ///   }
  ///   return null;
  /// })
  /// ```
  static FkValidator<T> custom<T>(FkValidationResult? Function(T?) fn) =>
      _CustomValidator<T>(fn);

  // ---------------------------------------------------------------------------
  // Cross-field validators
  // ---------------------------------------------------------------------------

  /// Validates that this field's value matches the value of [otherFieldName].
  ///
  /// Requires an [FkValidationContext] to access sibling field values.
  ///
  /// ```dart
  /// Fk.matchFields('password', message: 'Passwords must match')
  /// ```
  static FkValidator<T> matchFields<T>(
    String otherFieldName, {
    String? message,
  }) =>
      _MatchFieldsValidator<T>(otherFieldName, message);

  // ---------------------------------------------------------------------------
  // Async validators
  // ---------------------------------------------------------------------------

  /// Creates an async validator that checks uniqueness via the [checker] callback.
  ///
  /// The [checker] should return `true` if the value is unique (valid),
  /// or `false` if it already exists (invalid).
  ///
  /// ```dart
  /// Fk.unique<String>((value) async {
  ///   return await api.isUsernameAvailable(value!);
  /// })
  /// ```
  static FkAsyncValidator<T> unique<T>(
    Future<bool> Function(T?) checker, {
    String? message,
  }) =>
      _UniqueAsyncValidator<T>(checker, message);
}

// =============================================================================
// Private validator implementations
// =============================================================================

class _RequiredValidator<T> extends FkValidator<T> {
  final String? _message;

  const _RequiredValidator(this._message);

  @override
  FkValidationResult? validate(T? value, [FkValidationContext? context]) {
    if (value == null) {
      return FkValidationResult(
        _message ?? 'This field is required',
        code: 'required',
      );
    }

    if (value is String && value.trim().isEmpty) {
      return FkValidationResult(
        _message ?? 'This field is required',
        code: 'required',
      );
    }

    return null;
  }
}

class _EmailValidator extends FkValidator<String> {
  final String? _message;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  const _EmailValidator(this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_emailRegex.hasMatch(value)) {
      return FkValidationResult(
        _message ?? 'Invalid email address',
        code: 'email',
      );
    }

    return null;
  }
}

class _MinLengthValidator extends FkValidator<String> {
  final int _min;
  final String? _message;

  const _MinLengthValidator(this._min, this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < _min) {
      return FkValidationResult(
        _message ?? 'Must be at least $_min characters',
        code: 'min_length',
        params: {'min': _min, 'actual': value.length},
      );
    }

    return null;
  }
}

class _MaxLengthValidator extends FkValidator<String> {
  final int _max;
  final String? _message;

  const _MaxLengthValidator(this._max, this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (value.length > _max) {
      return FkValidationResult(
        _message ?? 'Must be at most $_max characters',
        code: 'max_length',
        params: {'max': _max, 'actual': value.length},
      );
    }

    return null;
  }
}

class _PatternValidator extends FkValidator<String> {
  final RegExp _regex;
  final String? _message;

  const _PatternValidator(this._regex, this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_regex.hasMatch(value)) {
      return FkValidationResult(
        _message ?? 'Invalid format',
        code: 'pattern',
        params: {'pattern': _regex.pattern},
      );
    }

    return null;
  }
}

class _UrlValidator extends FkValidator<String> {
  final String? _message;

  static final _urlRegex = RegExp(
    r'^(https?|ftp):\/\/'
    r'[^\s/$.?#]'
    r'[^\s]*$',
    caseSensitive: false,
  );

  const _UrlValidator(this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_urlRegex.hasMatch(value)) {
      return FkValidationResult(
        _message ?? 'Invalid URL',
        code: 'url',
      );
    }

    return null;
  }
}

class _PhoneValidator extends FkValidator<String> {
  final String? _message;

  static final _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]{7,}$',
  );

  const _PhoneValidator(this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_phoneRegex.hasMatch(value)) {
      return FkValidationResult(
        _message ?? 'Invalid phone number',
        code: 'phone',
      );
    }

    return null;
  }
}

class _CreditCardValidator extends FkValidator<String> {
  final String? _message;

  const _CreditCardValidator(this._message);

  @override
  FkValidationResult? validate(String? value, [FkValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 13 || digits.length > 19 || !_luhnCheck(digits)) {
      return FkValidationResult(
        _message ?? 'Invalid credit card number',
        code: 'credit_card',
      );
    }

    return null;
  }

  /// Implements the Luhn algorithm for credit card validation.
  static bool _luhnCheck(String digits) {
    var sum = 0;
    var alternate = false;

    for (var i = digits.length - 1; i >= 0; i--) {
      var n = int.parse(digits[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
}

class _MinValidator extends FkValidator<num> {
  final num _min;
  final String? _message;

  const _MinValidator(this._min, this._message);

  @override
  FkValidationResult? validate(num? value, [FkValidationContext? context]) {
    if (value == null) return null;

    if (value < _min) {
      return FkValidationResult(
        _message ?? 'Must be at least $_min',
        code: 'min',
        params: {'min': _min, 'actual': value},
      );
    }

    return null;
  }
}

class _MaxValidator extends FkValidator<num> {
  final num _max;
  final String? _message;

  const _MaxValidator(this._max, this._message);

  @override
  FkValidationResult? validate(num? value, [FkValidationContext? context]) {
    if (value == null) return null;

    if (value > _max) {
      return FkValidationResult(
        _message ?? 'Must be at most $_max',
        code: 'max',
        params: {'max': _max, 'actual': value},
      );
    }

    return null;
  }
}

class _BetweenValidator extends FkValidator<num> {
  final num _min;
  final num _max;
  final String? _message;

  const _BetweenValidator(this._min, this._max, this._message);

  @override
  FkValidationResult? validate(num? value, [FkValidationContext? context]) {
    if (value == null) return null;

    if (value < _min || value > _max) {
      return FkValidationResult(
        _message ?? 'Must be between $_min and $_max',
        code: 'between',
        params: {'min': _min, 'max': _max, 'actual': value},
      );
    }

    return null;
  }
}

class _AfterDateValidator extends FkValidator<DateTime> {
  final DateTime _date;
  final String? _message;

  const _AfterDateValidator(this._date, this._message);

  @override
  FkValidationResult? validate(
    DateTime? value, [
    FkValidationContext? context,
  ]) {
    if (value == null) return null;

    if (!value.isAfter(_date)) {
      return FkValidationResult(
        _message ??
            'Must be after ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        code: 'after',
        params: {'date': _date.toIso8601String(), 'actual': value.toIso8601String()},
      );
    }

    return null;
  }
}

class _BeforeDateValidator extends FkValidator<DateTime> {
  final DateTime _date;
  final String? _message;

  const _BeforeDateValidator(this._date, this._message);

  @override
  FkValidationResult? validate(
    DateTime? value, [
    FkValidationContext? context,
  ]) {
    if (value == null) return null;

    if (!value.isBefore(_date)) {
      return FkValidationResult(
        _message ??
            'Must be before ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        code: 'before',
        params: {'date': _date.toIso8601String(), 'actual': value.toIso8601String()},
      );
    }

    return null;
  }
}

class _AgeValidator extends FkValidator<DateTime> {
  final int _minimumAge;
  final String? _message;

  const _AgeValidator(this._minimumAge, this._message);

  @override
  FkValidationResult? validate(
    DateTime? value, [
    FkValidationContext? context,
  ]) {
    if (value == null) return null;

    final now = DateTime.now();
    var age = now.year - value.year;

    // Adjust if the birthday hasn't occurred yet this year
    if (now.month < value.month ||
        (now.month == value.month && now.day < value.day)) {
      age--;
    }

    if (age < _minimumAge) {
      return FkValidationResult(
        _message ?? 'Must be at least $_minimumAge years old',
        code: 'age',
        params: {'min': _minimumAge, 'actual': age},
      );
    }

    return null;
  }
}

class _EqualsValidator<T> extends FkValidator<T> {
  final T _expected;
  final String? _message;

  const _EqualsValidator(this._expected, this._message);

  @override
  FkValidationResult? validate(T? value, [FkValidationContext? context]) {
    if (value == null) return null;

    if (value != _expected) {
      return FkValidationResult(
        _message ?? 'Value must equal $_expected',
        code: 'equals',
        params: {'expected': _expected, 'actual': value},
      );
    }

    return null;
  }
}

class _CustomValidator<T> extends FkValidator<T> {
  final FkValidationResult? Function(T?) _fn;

  const _CustomValidator(this._fn);

  @override
  FkValidationResult? validate(T? value, [FkValidationContext? context]) {
    return _fn(value);
  }
}

class _MatchFieldsValidator<T> extends FkValidator<T> {
  final String _otherFieldName;
  final String? _message;

  const _MatchFieldsValidator(this._otherFieldName, this._message);

  @override
  FkValidationResult? validate(T? value, [FkValidationContext? context]) {
    if (context == null || value == null) return null;

    final otherValue = context.sibling<T>(_otherFieldName);

    if (value != otherValue) {
      return FkValidationResult(
        _message ?? 'Fields do not match',
        code: 'match_fields',
        params: {'otherField': _otherFieldName},
      );
    }

    return null;
  }
}

class _UniqueAsyncValidator<T> extends FkAsyncValidator<T> {
  final Future<bool> Function(T?) _checker;
  final String? _message;

  const _UniqueAsyncValidator(this._checker, this._message);

  @override
  Future<FkValidationResult?> validate(
    T? value, [
    FkValidationContext? context,
  ]) async {
    if (value == null) return null;

    final isUnique = await _checker(value);

    if (!isUnique) {
      return FkValidationResult(
        _message ?? 'This value is already taken',
        code: 'unique',
      );
    }

    return null;
  }
}
