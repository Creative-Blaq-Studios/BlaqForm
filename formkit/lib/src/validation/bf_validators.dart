import 'bf_async_validator.dart';
import 'bf_validation_context.dart';
import 'bf_validation_result.dart';
import 'bf_validator.dart';

/// The `Bf` namespace provides static factory methods for all prebuilt
/// validators in FlutterFormKit.
///
/// All validators return user-friendly default messages and support
/// an optional custom [message] override.
///
/// ```dart
/// final controller = BfFieldController<String>(
///   validators: [
///     Bf.required(),
///     Bf.email(),
///     Bf.minLength(8),
///   ],
/// );
/// ```
abstract class Bf {
  // ---------------------------------------------------------------------------
  // String validators
  // ---------------------------------------------------------------------------

  /// Validates that the value is not null and not empty.
  ///
  /// Works on any type. For [String] values, also checks that the string
  /// is not empty after trimming.
  ///
  /// ```dart
  /// Bf.required() // "This field is required"
  /// Bf.required(message: 'Please enter your name')
  /// ```
  static BfValidator<T> required<T>({String? message}) =>
      _RequiredValidator<T>(message);

  /// Validates that the string is a valid email address.
  ///
  /// Uses a regex pattern that covers common email formats.
  ///
  /// ```dart
  /// Bf.email() // "Invalid email address"
  /// ```
  static BfValidator<String> email({String? message}) =>
      _EmailValidator(message);

  /// Validates that the string has at least [min] characters.
  ///
  /// ```dart
  /// Bf.minLength(8) // "Must be at least 8 characters"
  /// ```
  static BfValidator<String> minLength(int min, {String? message}) =>
      _MinLengthValidator(min, message);

  /// Validates that the string has at most [max] characters.
  ///
  /// ```dart
  /// Bf.maxLength(100) // "Must be at most 100 characters"
  /// ```
  static BfValidator<String> maxLength(int max, {String? message}) =>
      _MaxLengthValidator(max, message);

  /// Validates that the string matches the given [regex] pattern.
  ///
  /// ```dart
  /// Bf.pattern(RegExp(r'^[A-Z]'), message: 'Must start with uppercase')
  /// ```
  static BfValidator<String> pattern(RegExp regex, {String? message}) =>
      _PatternValidator(regex, message);

  /// Validates that the string is a valid URL.
  ///
  /// Accepts `http`, `https`, and `ftp` schemes.
  ///
  /// ```dart
  /// Bf.url() // "Invalid URL"
  /// ```
  static BfValidator<String> url({String? message}) => _UrlValidator(message);

  /// Validates that the string is a valid phone number.
  ///
  /// Accepts digits, spaces, dashes, parentheses, and an optional
  /// leading `+`. Requires at least 7 digits.
  ///
  /// ```dart
  /// Bf.phone() // "Invalid phone number"
  /// ```
  static BfValidator<String> phone({String? message}) =>
      _PhoneValidator(message);

  /// Validates that the string is a valid credit card number.
  ///
  /// Uses the Luhn algorithm to verify the card number.
  ///
  /// ```dart
  /// Bf.creditCard() // "Invalid credit card number"
  /// ```
  static BfValidator<String> creditCard({String? message}) =>
      _CreditCardValidator(message);

  // ---------------------------------------------------------------------------
  // Numeric validators
  // ---------------------------------------------------------------------------

  /// Validates that the numeric value is at least [min].
  ///
  /// ```dart
  /// Bf.min(0) // "Must be at least 0"
  /// ```
  static BfValidator<num> min(num min, {String? message}) =>
      _MinValidator(min, message);

  /// Validates that the numeric value is at most [max].
  ///
  /// ```dart
  /// Bf.max(100) // "Must be at most 100"
  /// ```
  static BfValidator<num> max(num max, {String? message}) =>
      _MaxValidator(max, message);

  /// Validates that the numeric value is between [min] and [max] (inclusive).
  ///
  /// ```dart
  /// Bf.between(1, 10) // "Must be between 1 and 10"
  /// ```
  static BfValidator<num> between(num min, num max, {String? message}) =>
      _BetweenValidator(min, max, message);

  // ---------------------------------------------------------------------------
  // Date validators
  // ---------------------------------------------------------------------------

  /// Validates that the date is after [date].
  ///
  /// ```dart
  /// Bf.after(DateTime(2024, 1, 1)) // "Must be after 2024-01-01"
  /// ```
  static BfValidator<DateTime> after(DateTime date, {String? message}) =>
      _AfterDateValidator(date, message);

  /// Validates that the date is before [date].
  ///
  /// ```dart
  /// Bf.before(DateTime(2030, 1, 1)) // "Must be before 2030-01-01"
  /// ```
  static BfValidator<DateTime> before(DateTime date, {String? message}) =>
      _BeforeDateValidator(date, message);

  /// Validates that the date represents an age of at least [minimumAge] years.
  ///
  /// Compares the date against the current date to determine age.
  ///
  /// ```dart
  /// Bf.age(18) // "Must be at least 18 years old"
  /// ```
  static BfValidator<DateTime> age(int minimumAge, {String? message}) =>
      _AgeValidator(minimumAge, message);

  // ---------------------------------------------------------------------------
  // Generic validators
  // ---------------------------------------------------------------------------

  /// Validates that the value equals [expected].
  ///
  /// ```dart
  /// Bf.equals('yes') // "Value must equal yes"
  /// ```
  static BfValidator<T> equals<T>(T expected, {String? message}) =>
      _EqualsValidator<T>(expected, message);

  /// Creates a validator from a custom callback function.
  ///
  /// Return `null` from [fn] if the value is valid, or an
  /// [BfValidationResult] if invalid.
  ///
  /// ```dart
  /// Bf.custom<String>((value) {
  ///   if (value?.contains('bad') ?? false) {
  ///     return BfValidationResult('Contains forbidden word');
  ///   }
  ///   return null;
  /// })
  /// ```
  static BfValidator<T> custom<T>(BfValidationResult? Function(T?) fn) =>
      _CustomValidator<T>(fn);

  // ---------------------------------------------------------------------------
  // Cross-field validators
  // ---------------------------------------------------------------------------

  /// Validates that this field's value matches the value of [otherFieldName].
  ///
  /// Requires an [BfValidationContext] to access sibling field values.
  ///
  /// ```dart
  /// Bf.matchFields('password', message: 'Passwords must match')
  /// ```
  static BfValidator<T> matchFields<T>(
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
  /// Bf.unique<String>((value) async {
  ///   return await api.isUsernameAvailable(value!);
  /// })
  /// ```
  static BfAsyncValidator<T> unique<T>(
    Future<bool> Function(T?) checker, {
    String? message,
  }) =>
      _UniqueAsyncValidator<T>(checker, message);
}

// =============================================================================
// Private validator implementations
// =============================================================================

class _RequiredValidator<T> extends BfValidator<T> {
  final String? _message;

  const _RequiredValidator(this._message);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    if (value == null) {
      return BfValidationResult(
        _message ?? 'This field is required',
        code: 'required',
      );
    }

    if (value is String && value.trim().isEmpty) {
      return BfValidationResult(
        _message ?? 'This field is required',
        code: 'required',
      );
    }

    return null;
  }
}

class _EmailValidator extends BfValidator<String> {
  final String? _message;

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  const _EmailValidator(this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_emailRegex.hasMatch(value)) {
      return BfValidationResult(
        _message ?? 'Invalid email address',
        code: 'email',
      );
    }

    return null;
  }
}

class _MinLengthValidator extends BfValidator<String> {
  final int _min;
  final String? _message;

  const _MinLengthValidator(this._min, this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (value.length < _min) {
      return BfValidationResult(
        _message ?? 'Must be at least $_min characters',
        code: 'min_length',
        params: {'min': _min, 'actual': value.length},
      );
    }

    return null;
  }
}

class _MaxLengthValidator extends BfValidator<String> {
  final int _max;
  final String? _message;

  const _MaxLengthValidator(this._max, this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (value.length > _max) {
      return BfValidationResult(
        _message ?? 'Must be at most $_max characters',
        code: 'max_length',
        params: {'max': _max, 'actual': value.length},
      );
    }

    return null;
  }
}

class _PatternValidator extends BfValidator<String> {
  final RegExp _regex;
  final String? _message;

  const _PatternValidator(this._regex, this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_regex.hasMatch(value)) {
      return BfValidationResult(
        _message ?? 'Invalid format',
        code: 'pattern',
        params: {'pattern': _regex.pattern},
      );
    }

    return null;
  }
}

class _UrlValidator extends BfValidator<String> {
  final String? _message;

  static final _urlRegex = RegExp(
    r'^(https?|ftp):\/\/'
    r'[^\s/$.?#]'
    r'[^\s]*$',
    caseSensitive: false,
  );

  const _UrlValidator(this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_urlRegex.hasMatch(value)) {
      return BfValidationResult(
        _message ?? 'Invalid URL',
        code: 'url',
      );
    }

    return null;
  }
}

class _PhoneValidator extends BfValidator<String> {
  final String? _message;

  static final _phoneRegex = RegExp(
    r'^\+?[\d\s\-\(\)]{7,}$',
  );

  const _PhoneValidator(this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    if (!_phoneRegex.hasMatch(value)) {
      return BfValidationResult(
        _message ?? 'Invalid phone number',
        code: 'phone',
      );
    }

    return null;
  }
}

class _CreditCardValidator extends BfValidator<String> {
  final String? _message;

  const _CreditCardValidator(this._message);

  @override
  BfValidationResult? validate(String? value, [BfValidationContext? context]) {
    if (value == null || value.isEmpty) return null;

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length < 13 || digits.length > 19 || !_luhnCheck(digits)) {
      return BfValidationResult(
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

class _MinValidator extends BfValidator<num> {
  final num _min;
  final String? _message;

  const _MinValidator(this._min, this._message);

  @override
  BfValidationResult? validate(num? value, [BfValidationContext? context]) {
    if (value == null) return null;

    if (value < _min) {
      return BfValidationResult(
        _message ?? 'Must be at least $_min',
        code: 'min',
        params: {'min': _min, 'actual': value},
      );
    }

    return null;
  }
}

class _MaxValidator extends BfValidator<num> {
  final num _max;
  final String? _message;

  const _MaxValidator(this._max, this._message);

  @override
  BfValidationResult? validate(num? value, [BfValidationContext? context]) {
    if (value == null) return null;

    if (value > _max) {
      return BfValidationResult(
        _message ?? 'Must be at most $_max',
        code: 'max',
        params: {'max': _max, 'actual': value},
      );
    }

    return null;
  }
}

class _BetweenValidator extends BfValidator<num> {
  final num _min;
  final num _max;
  final String? _message;

  const _BetweenValidator(this._min, this._max, this._message);

  @override
  BfValidationResult? validate(num? value, [BfValidationContext? context]) {
    if (value == null) return null;

    if (value < _min || value > _max) {
      return BfValidationResult(
        _message ?? 'Must be between $_min and $_max',
        code: 'between',
        params: {'min': _min, 'max': _max, 'actual': value},
      );
    }

    return null;
  }
}

class _AfterDateValidator extends BfValidator<DateTime> {
  final DateTime _date;
  final String? _message;

  const _AfterDateValidator(this._date, this._message);

  @override
  BfValidationResult? validate(
    DateTime? value, [
    BfValidationContext? context,
  ]) {
    if (value == null) return null;

    if (!value.isAfter(_date)) {
      return BfValidationResult(
        _message ??
            'Must be after ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        code: 'after',
        params: {'date': _date.toIso8601String(), 'actual': value.toIso8601String()},
      );
    }

    return null;
  }
}

class _BeforeDateValidator extends BfValidator<DateTime> {
  final DateTime _date;
  final String? _message;

  const _BeforeDateValidator(this._date, this._message);

  @override
  BfValidationResult? validate(
    DateTime? value, [
    BfValidationContext? context,
  ]) {
    if (value == null) return null;

    if (!value.isBefore(_date)) {
      return BfValidationResult(
        _message ??
            'Must be before ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
        code: 'before',
        params: {'date': _date.toIso8601String(), 'actual': value.toIso8601String()},
      );
    }

    return null;
  }
}

class _AgeValidator extends BfValidator<DateTime> {
  final int _minimumAge;
  final String? _message;

  const _AgeValidator(this._minimumAge, this._message);

  @override
  BfValidationResult? validate(
    DateTime? value, [
    BfValidationContext? context,
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
      return BfValidationResult(
        _message ?? 'Must be at least $_minimumAge years old',
        code: 'age',
        params: {'min': _minimumAge, 'actual': age},
      );
    }

    return null;
  }
}

class _EqualsValidator<T> extends BfValidator<T> {
  final T _expected;
  final String? _message;

  const _EqualsValidator(this._expected, this._message);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    if (value == null) return null;

    if (value != _expected) {
      return BfValidationResult(
        _message ?? 'Value must equal $_expected',
        code: 'equals',
        params: {'expected': _expected, 'actual': value},
      );
    }

    return null;
  }
}

class _CustomValidator<T> extends BfValidator<T> {
  final BfValidationResult? Function(T?) _fn;

  const _CustomValidator(this._fn);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    return _fn(value);
  }
}

class _MatchFieldsValidator<T> extends BfValidator<T> {
  final String _otherFieldName;
  final String? _message;

  const _MatchFieldsValidator(this._otherFieldName, this._message);

  @override
  BfValidationResult? validate(T? value, [BfValidationContext? context]) {
    if (context == null || value == null) return null;

    final otherValue = context.sibling<T>(_otherFieldName);

    if (value != otherValue) {
      return BfValidationResult(
        _message ?? 'Fields do not match',
        code: 'match_fields',
        params: {'otherField': _otherFieldName},
      );
    }

    return null;
  }
}

class _UniqueAsyncValidator<T> extends BfAsyncValidator<T> {
  final Future<bool> Function(T?) _checker;
  final String? _message;

  const _UniqueAsyncValidator(this._checker, this._message);

  @override
  Future<BfValidationResult?> validate(
    T? value, [
    BfValidationContext? context,
  ]) async {
    if (value == null) return null;

    final isUnique = await _checker(value);

    if (!isUnique) {
      return BfValidationResult(
        _message ?? 'This value is already taken',
        code: 'unique',
      );
    }

    return null;
  }
}
