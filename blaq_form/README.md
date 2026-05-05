# BlaqForm

A composable, extensible Flutter forms package with prebuilt validations, adaptive field types, and a developer-first API.

BlaqForm is **state-management agnostic** — it works with `setState`, Riverpod, Bloc, or vanilla `ChangeNotifier`. Controllers are atomic, validators compose, and fields auto-register with the nearest form.

## Features

- **17 prebuilt fields** — text, email, password, phone, OTP, currency, dropdown, autocomplete, checkbox(es), radio group, chip select, switch, slider, range slider, rating, date, date range, signature.
- **Composable validators** — `Bf.required()`, `Bf.email()`, `Bf.minLength()`, `Bf.matchFields()`, `Bf.equals()`, and more. Combine with `.and()`, `.or()`, `.when()`. Async validators supported.
- **Two API styles** — imperative (`BfFieldController` + widgets) for full control, or declarative (`BfFormBuilder`) for zero boilerplate.
- **Auto-registration** — drop a field inside a `BfForm` and it wires itself up. No keys, no manual lists.
- **Multi-step flows** — `BfWizard` with per-step validation gating.
- **Themeable** — `BfFormTheme` `ThemeExtension` inherits Material/Cupertino with overrides.
- **Tiny core** — zero external dependencies (Flutter SDK only).

## Getting started

Add the dependency:

```yaml
dependencies:
  blaq_form: ^0.0.1
```

Import it:

```dart
import 'package:blaq_form/blaq_form.dart';
```

## Usage

### Declarative — `BfFormBuilder`

The shortest path to a working form. No `StatefulWidget`, no manual `dispose`.

```dart
BfFormBuilder(
  fields: {
    'email': BfFieldConfig<String>.email(
      label: 'Email',
      validators: [Bf.required(), Bf.email()],
    ),
    'password': BfFieldConfig<String>.password(
      label: 'Password',
      validators: [Bf.required(), Bf.minLength(8)],
    ),
  },
  onSubmit: (values) async {
    await api.signIn(values['email'], values['password']);
  },
  builder: (form) => Column(
    children: [
      form.email('email'),
      const SizedBox(height: 16),
      form.password('password'),
      const SizedBox(height: 24),
      form.submitButton('Sign in'),
    ],
  ),
)
```

### Imperative — controllers + widgets

When you need full control over individual field state.

```dart
final form = BfFormController();

final email = BfFieldController<String>(
  validators: [Bf.required(), Bf.email()],
);

final password = BfFieldController<String>(
  validators: [Bf.required(), Bf.minLength(8)],
);

// In build():
BfForm(
  controller: form,
  child: Column(
    children: [
      BfTextField.email(controller: email, label: 'Email'),
      BfTextField.password(controller: password, label: 'Password'),
      BfSubmitButton(
        label: 'Sign in',
        onSubmit: (form) => form.submit((values) async {
          await api.signIn(values['email'], values['password']);
        }),
      ),
    ],
  ),
)
```

### Cross-field validation

```dart
BfFieldController<String>(
  validators: [
    Bf.required(),
    Bf.matchFields<String>('password', message: 'Passwords do not match'),
  ],
)
```

The form controller passes a `BfValidationContext` so any validator can read sibling field values.

## Examples

The [`example/`](example/) directory contains four complete forms:

- **Signup form** — text/email/password fields with cross-field matching.
- **Checkout form** — sections, side-by-side rows, dropdown, date picker.
- **Builder signup** — the same signup form rewritten with `BfFormBuilder` (~50 lines).
- **Wizard onboarding** — multi-step flow with per-step validation.

```bash
cd example && flutter run
```

## Architecture

BlaqForm is layered so each piece is independently usable:

| Layer       | Purpose                                                      |
| ----------- | ------------------------------------------------------------ |
| State       | `BfFieldController<T>`, `BfFormController` (`ChangeNotifier`)|
| Validation  | `BfValidator<T>`, `BfAsyncValidator<T>`, `Bf.*` prebuilts    |
| Field       | Widgets that auto-register via `BfFieldMixin<T>`             |
| Consumer    | `BfForm`, `BfFormSection`, `BfFormRow`, `BfSubmitButton`     |
| Theme       | `BfFormTheme` `ThemeExtension`                               |

## Contributing

Issues and PRs welcome at [github.com/creativeblaq/BlaqForm](https://github.com/creativeblaq/BlaqForm).

## License

MIT — see [LICENSE](LICENSE).
