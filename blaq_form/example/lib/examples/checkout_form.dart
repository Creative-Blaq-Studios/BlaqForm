import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blaq_form/blaq_form.dart';

import '../theme/app_theme.dart';
import '../widgets/brand_scaffold.dart';

class CheckoutFormExample extends StatefulWidget {
  const CheckoutFormExample({required this.notifier, super.key});

  final AppThemeNotifier notifier;

  @override
  State<CheckoutFormExample> createState() => _CheckoutFormExampleState();
}

class _CheckoutFormExampleState extends State<CheckoutFormExample> {
  late final BfFormController _formController;
  late final BfFieldController<String> _firstNameController;
  late final BfFieldController<String> _lastNameController;
  late final BfFieldController<String> _emailController;
  late final BfFieldController<String> _cardNumberController;
  late final BfFieldController<String> _cardHolderController;
  late final BfFieldController<DateTime> _expiryDateController;
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
    _firstNameController = BfFieldController<String>(
      validators: [Bf.required(message: 'First name required')],
    );
    _lastNameController = BfFieldController<String>(
      validators: [Bf.required(message: 'Last name required')],
    );
    _emailController = BfFieldController<String>(
      validators: [Bf.required(), Bf.email()],
    );
    _cardNumberController = BfFieldController<String>(
      validators: [Bf.required(), Bf.creditCard()],
    );
    _cardHolderController = BfFieldController<String>(
      validators: [Bf.required(message: 'Cardholder name required')],
    );
    _expiryDateController = BfFieldController<DateTime>(
      validators: [
        Bf.required(message: 'Expiry date required'),
        Bf.after(DateTime.now(), message: 'Card has expired'),
      ],
    );
    _addressController = BfFieldController<String>(
      validators: [Bf.required(message: 'Address required')],
    );
    _cityController = BfFieldController<String>(
      validators: [Bf.required(message: 'City required')],
    );
    _zipCodeController = BfFieldController<String>(
      validators: [Bf.required(), Bf.minLength(4)],
    );
    _countryController = BfFieldController<String>(
      validators: [Bf.required(message: 'Select a country')],
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
    return BrandScaffold(
      notifier: widget.notifier,
      title: 'Checkout',
      body: BfDirtyGuard(
        controller: _formController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: BfForm(
            controller: _formController,
            autovalidateMode: BfAutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BrandSection(
                  tag: '01',
                  title: 'Personal Information',
                  child: Column(
                    children: [
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
                      const SizedBox(height: 16),
                      BfTextField.email(
                        name: 'email',
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _BrandSection(
                  tag: '02',
                  title: 'Payment',
                  child: Column(
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
                      const SizedBox(height: 16),
                      BfTextField(
                        name: 'cardHolder',
                        controller: _cardHolderController,
                        labelText: 'Cardholder Name',
                        prefixIcon: const Icon(Icons.person_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
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
                ),
                const SizedBox(height: 24),
                _BrandSection(
                  tag: '03',
                  title: 'Shipping Address',
                  child: Column(
                    children: [
                      BfTextField(
                        name: 'address',
                        controller: _addressController,
                        labelText: 'Street Address',
                        hintText: '123 Main St',
                        prefixIcon: const Icon(Icons.home_outlined),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
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
                            labelText: 'ZIP',
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                ),
                const SizedBox(height: 28),
                _OrderSummary(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  countryController: _countryController,
                ),
                const SizedBox(height: 16),
                BfSubmitButton(
                  label: 'Place Order',
                  disableWhenInvalid: false,
                  onSubmit: (controller) async {
                    final success = await controller.submit((values) async {
                      await Future.delayed(const Duration(seconds: 2));
                    });
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed!')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({
    required this.tag,
    required this.title,
    required this.child,
  });

  final String tag;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '// $tag',
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 10,
                color: Color(0xFFFF6B00),
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.1,
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Divider(color: cs.outline, thickness: 1, height: 1),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.firstNameController,
    required this.lastNameController,
    required this.countryController,
  });

  final BfFieldController<String> firstNameController;
  final BfFieldController<String> lastNameController;
  final BfFieldController<String> countryController;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: Listenable.merge([
        firstNameController,
        lastNameController,
        countryController,
      ]),
      builder: (context, _) {
        final name = [
          firstNameController.value ?? '',
          lastNameController.value ?? '',
        ].where((s) => s.isNotEmpty).join(' ');
        final country = countryController.value ?? '—';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '// order summary',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: Color(0xFFFF6B00),
                ),
              ),
              const SizedBox(height: 12),
              _SummaryRow(label: 'Name', value: name.isEmpty ? '—' : name),
              _SummaryRow(label: 'Ship to', value: country),
              const _SummaryRow(label: 'Total', value: '\$49.00'),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

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
