# Changelog

## 0.0.1

Initial release.

### Core
- `BfFieldController<T>` and `BfFormController` — `ChangeNotifier`-based controllers that own value, dirty/touched, and validation state. State-management agnostic (works with `setState`, Riverpod, Bloc, or any `ChangeNotifier` consumer).
- `BfValidator<T>` and `BfAsyncValidator<T>` with `.and()`, `.or()`, `.when()` composition.
- Prebuilt validators on the `Bf` namespace: `Bf.required()`, `Bf.email()`, `Bf.minLength()`, `Bf.maxLength()`, and more.
- `BfValidationContext` and `BfValidationResult` for cross-field and structured error reporting.

### Fields
- Text: `BfTextField` (with `.password()` extension), `BfOtpField`, `BfPhoneField`, `BfCurrencyField`.
- Selection: `BfDropdown`, `BfAutocomplete`, `BfCheckboxField`, `BfCheckboxGroupField`, `BfRadioGroupField`, `BfChipSelectField`, `BfSwitchField`.
- Numeric: `BfSliderField`, `BfRangeSliderField`, `BfRatingField`.
- Date/time: `BfDateField`, `BfDateRangeField`.
- Specialty: `BfSignatureField`.

### Form shell & layout
- `BfForm`, `BfFormSection`, `BfFormRow`, `BfSubmitButton` with auto-registration of descendant fields.
- `BfFormBuilder` for fully declarative forms (zero `StatefulWidget`, zero manual `dispose`).
- `BfWizard` multi-step flow with per-step validation gating.

### Theme & DX
- `BfFormTheme` `ThemeExtension` that inherits from Material/Cupertino with overrides.
- `BfLogger` with configurable levels and colored console output.
- Persistence helpers and field-key constants for type-safe identifiers.
