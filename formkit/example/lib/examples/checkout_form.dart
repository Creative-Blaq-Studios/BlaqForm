import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blaq_form/blaq_form.dart';

/// A checkout form demonstrating layout and advanced field widgets:
///
/// - [BfFormSection] for grouping fields under titled sections
/// - [BfFormRow] for placing fields side-by-side (first/last name)
/// - [BfDropdownField] for country selection
/// - [BfDateField] for card expiry date
/// - [BfTextField] with credit card validation ([Bf.creditCard])
/// - Various validators: [Bf.required], [Bf.email], [Bf.creditCard],
///   [Bf.minLength], [Bf.before]
/// - [BfSubmitButton] tied to the form
class CheckoutFormExample extends StatefulWidget {
  const CheckoutFormExample({super.key});

  @override
  State<CheckoutFormExample> createState() => _CheckoutFormExampleState();
}

class _CheckoutFormExampleState extends State<CheckoutFormExample> {
  late final BfFormController _formController;

  // -- Personal info controllers --
  late final BfFieldController<String> _firstNameController;
  late final BfFieldController<String> _lastNameController;
  late final BfFieldController<String> _emailController;

  // -- Payment controllers --
  late final BfFieldController<String> _cardNumberController;
  late final BfFieldController<String> _cardHolderController;
  late final BfFieldController<DateTime> _expiryDateController;

  // -- Shipping controllers --
  late final BfFieldController<String> _addressController;
  late final BfFieldController<String> _cityController;
  late final BfFieldController<String> _zipCodeController;
  late final BfFieldController<String> _countryController;

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

    _formController = BfFormController();

    // -- Personal info --
    _firstNameController = BfFieldController<String>(
      validators: [Bf.required(message: 'First name is required')],
    );
    _lastNameController = BfFieldController<String>(
      validators: [Bf.required(message: 'Last name is required')],
    );
    _emailController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'Email is required'),
        Bf.email(),
      ],
    );

    // -- Payment --
    _cardNumberController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'Card number is required'),
        Bf.creditCard(),
      ],
    );
    _cardHolderController = BfFieldController<String>(
      validators: [Bf.required(message: 'Cardholder name is required')],
    );
    // Expiry must be in the future
    _expiryDateController = BfFieldController<DateTime>(
      validators: [
        Bf.required(message: 'Expiry date is required'),
        Bf.after(DateTime.now(), message: 'Card has expired'),
      ],
    );

    // -- Shipping --
    _addressController = BfFieldController<String>(
      validators: [Bf.required(message: 'Address is required')],
    );
    _cityController = BfFieldController<String>(
      validators: [Bf.required(message: 'City is required')],
    );
    _zipCodeController = BfFieldController<String>(
      validators: [
        Bf.required(message: 'ZIP code is required'),
        Bf.minLength(4, message: 'ZIP code is too short'),
      ],
    );
    _countryController = BfFieldController<String>(
      validators: [Bf.required(message: 'Please select a country')],
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
        child: BfForm(
          controller: _formController,
          autovalidateMode: BfAutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // Section 1: Personal Information
              // ---------------------------------------------------------------
              BfFormSection(
                title: 'Personal Information',
                description: 'We need your details to process the order.',
                children: [
                  // First and last name side-by-side using BfFormRow
                  BfFormRow(
                    children: [
                      BfTextField(
                        name: 'firstName',
                        controller: _firstNameController,
                        labelText: 'First Name',
                        textInputAction: TextInputAction.next,
                      ),
                      BfTextField(
                        name: 'lastName',
                        controller: _lastNameController,
                        labelText: 'Last Name',
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  BfTextField.email(
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
              BfFormSection(
                title: 'Payment',
                description: 'Enter your card details.',
                children: [
                  BfTextField(
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
                  BfTextField(
                    name: 'cardHolder',
                    controller: _cardHolderController,
                    labelText: 'Cardholder Name',
                    hintText: 'Name on card',
                    prefixIcon: const Icon(Icons.person_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  // Expiry date using the date picker field
                  BfDateField(
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
              BfFormSection(
                title: 'Shipping Address',
                description: 'Where should we deliver your order?',
                children: [
                  BfTextField(
                    name: 'address',
                    controller: _addressController,
                    labelText: 'Street Address',
                    hintText: '123 Main St',
                    prefixIcon: const Icon(Icons.home_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  // City and ZIP code side-by-side with custom flex ratios
                  BfFormRow(
                    flexes: const [2, 1],
                    children: [
                      BfTextField(
                        name: 'city',
                        controller: _cityController,
                        labelText: 'City',
                        textInputAction: TextInputAction.next,
                      ),
                      BfTextField(
                        name: 'zipCode',
                        controller: _zipCodeController,
                        labelText: 'ZIP Code',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                  // Country dropdown
                  BfDropdownField<String>(
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
              BfSubmitButton(
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
