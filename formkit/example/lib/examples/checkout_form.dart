import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formkit/formkit.dart';

/// A checkout form demonstrating layout and advanced field widgets:
///
/// - [FkFormSection] for grouping fields under titled sections
/// - [FkFormRow] for placing fields side-by-side (first/last name)
/// - [FkDropdownField] for country selection
/// - [FkDateField] for card expiry date
/// - [FkTextField] with credit card validation ([Fk.creditCard])
/// - Various validators: [Fk.required], [Fk.email], [Fk.creditCard],
///   [Fk.minLength], [Fk.before]
/// - [FkSubmitButton] tied to the form
class CheckoutFormExample extends StatefulWidget {
  const CheckoutFormExample({super.key});

  @override
  State<CheckoutFormExample> createState() => _CheckoutFormExampleState();
}

class _CheckoutFormExampleState extends State<CheckoutFormExample> {
  late final FkFormController _formController;

  // -- Personal info controllers --
  late final FkFieldController<String> _firstNameController;
  late final FkFieldController<String> _lastNameController;
  late final FkFieldController<String> _emailController;

  // -- Payment controllers --
  late final FkFieldController<String> _cardNumberController;
  late final FkFieldController<String> _cardHolderController;
  late final FkFieldController<DateTime> _expiryDateController;

  // -- Shipping controllers --
  late final FkFieldController<String> _addressController;
  late final FkFieldController<String> _cityController;
  late final FkFieldController<String> _zipCodeController;
  late final FkFieldController<String> _countryController;

  static const _countries = [
    'United States',
    'United Kingdom',
    'Canada',
    'Germany',
    'France',
    'Australia',
    'Japan',
    'Brazil',
  ];

  @override
  void initState() {
    super.initState();

    _formController = FkFormController();

    // -- Personal info --
    _firstNameController = FkFieldController<String>(
      validators: [Fk.required(message: 'First name is required')],
    );
    _lastNameController = FkFieldController<String>(
      validators: [Fk.required(message: 'Last name is required')],
    );
    _emailController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'Email is required'),
        Fk.email(),
      ],
    );

    // -- Payment --
    _cardNumberController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'Card number is required'),
        Fk.creditCard(),
      ],
    );
    _cardHolderController = FkFieldController<String>(
      validators: [Fk.required(message: 'Cardholder name is required')],
    );
    // Expiry must be in the future
    _expiryDateController = FkFieldController<DateTime>(
      validators: [
        Fk.required(message: 'Expiry date is required'),
        Fk.after(DateTime.now(), message: 'Card has expired'),
      ],
    );

    // -- Shipping --
    _addressController = FkFieldController<String>(
      validators: [Fk.required(message: 'Address is required')],
    );
    _cityController = FkFieldController<String>(
      validators: [Fk.required(message: 'City is required')],
    );
    _zipCodeController = FkFieldController<String>(
      validators: [
        Fk.required(message: 'ZIP code is required'),
        Fk.minLength(4, message: 'ZIP code is too short'),
      ],
    );
    _countryController = FkFieldController<String>(
      validators: [Fk.required(message: 'Please select a country')],
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryDateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FkForm(
          controller: _formController,
          autovalidateMode: FkAutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // Section 1: Personal Information
              // ---------------------------------------------------------------
              FkFormSection(
                title: 'Personal Information',
                description: 'We need your details to process the order.',
                children: [
                  // First and last name side-by-side using FkFormRow
                  FkFormRow(
                    children: [
                      FkTextField(
                        name: 'firstName',
                        controller: _firstNameController,
                        labelText: 'First Name',
                        textInputAction: TextInputAction.next,
                      ),
                      FkTextField(
                        name: 'lastName',
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  FkTextField.email(
                    name: 'email',
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'order-confirmation@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Section 2: Payment
              // ---------------------------------------------------------------
              FkFormSection(
                title: 'Payment',
                description: 'Enter your card details.',
                children: [
                  FkTextField(
                    name: 'cardNumber',
                    controller: _cardNumberController,
                    labelText: 'Card Number',
                    hintText: '4242 4242 4242 4242',
                    prefixIcon: const Icon(Icons.credit_card),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19),
                      _CardNumberFormatter(),
                    ],
                    textInputAction: TextInputAction.next,
                  ),
                  FkTextField(
                    name: 'cardHolder',
                    controller: _cardHolderController,
                    labelText: 'Cardholder Name',
                    hintText: 'Name on card',
                    prefixIcon: const Icon(Icons.person_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  // Expiry date using the date picker field
                  FkDateField(
                    name: 'expiryDate',
                    controller: _expiryDateController,
                    labelText: 'Expiry Date',
                    hintText: 'Select expiry date',
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2040),
                    dateFormat: 'MM/yyyy',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // Section 3: Shipping
              // ---------------------------------------------------------------
              FkFormSection(
                title: 'Shipping Address',
                description: 'Where should we deliver your order?',
                children: [
                  FkTextField(
                    name: 'address',
                    controller: _addressController,
                    labelText: 'Street Address',
                    hintText: '123 Main St',
                    prefixIcon: const Icon(Icons.home_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  // City and ZIP code side-by-side with custom flex ratios
                  FkFormRow(
                    flexes: const [2, 1],
                    children: [
                      FkTextField(
                        name: 'city',
                        controller: _cityController,
                        labelText: 'City',
                        textInputAction: TextInputAction.next,
                      ),
                      FkTextField(
                        name: 'zipCode',
                        controller: _zipCodeController,
                        labelText: 'ZIP Code',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  // Country dropdown
                  FkDropdownField<String>(
                    name: 'country',
                    controller: _countryController,
                    labelText: 'Country',
                    hintText: 'Select a country',
                    items: _countries
                        .map(
                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ---------------------------------------------------------------
              // Submit
              // ---------------------------------------------------------------
              FkSubmitButton(
                label: 'Place Order',
                disableWhenInvalid: false,
                onSubmit: (controller) async {
                  final success = await controller.submit((values) async {
                    // Simulate a network call
                    await Future.delayed(const Duration(seconds: 2));
                    debugPrint('Checkout values: $values');
                  });

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order placed successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// A [TextInputFormatter] that inserts spaces every 4 digits to visually
/// format a credit card number as the user types.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
