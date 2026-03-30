/// Predefined field name constants for common form fields.
///
/// Eliminates magic strings and gives you IDE autocomplete for field names.
///
/// ```dart
/// BfFormBuilder(
///   fields: {
///     BfUserKeys.email: BfFieldConfig.email(label: 'Email'),
///     BfUserKeys.password: BfFieldConfig.password(label: 'Password'),
///   },
///   builder: (context, form) => Column(children: [
///     form.email(BfUserKeys.email),
///     form.password(BfUserKeys.password),
///   ]),
/// )
/// ```
library;

// ---------------------------------------------------------------------------
// User / Account
// ---------------------------------------------------------------------------

/// Field keys for user identity and account fields.
abstract class BfUserKeys {
  static const username = 'username';
  static const email = 'email';
  static const password = 'password';
  static const confirmPassword = 'confirmPassword';
  static const currentPassword = 'currentPassword';
  static const newPassword = 'newPassword';
  static const pin = 'pin';
  static const otp = 'otp';

  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const middleName = 'middleName';
  static const fullName = 'fullName';
  static const displayName = 'displayName';
  static const nickname = 'nickname';
  static const suffix = 'suffix';
  static const prefix = 'prefix'; // Mr, Mrs, Dr, etc.
  static const title = 'title';

  static const dateOfBirth = 'dateOfBirth';
  static const age = 'age';
  static const gender = 'gender';
  static const pronouns = 'pronouns';
  static const avatar = 'avatar';
  static const profilePhoto = 'profilePhoto';
  static const bio = 'bio';
  static const about = 'about';
  static const website = 'website';
  static const language = 'language';
  static const timezone = 'timezone';
}

// ---------------------------------------------------------------------------
// Contact
// ---------------------------------------------------------------------------

/// Field keys for contact information.
abstract class BfContactKeys {
  static const phone = 'phone';
  static const phoneNumber = 'phoneNumber';
  static const mobilePhone = 'mobilePhone';
  static const homePhone = 'homePhone';
  static const workPhone = 'workPhone';
  static const fax = 'fax';

  static const email = 'email';
  static const personalEmail = 'personalEmail';
  static const workEmail = 'workEmail';

  static const emergencyContactName = 'emergencyContactName';
  static const emergencyContactPhone = 'emergencyContactPhone';
  static const emergencyContactRelation = 'emergencyContactRelation';
}

// ---------------------------------------------------------------------------
// Address
// ---------------------------------------------------------------------------

/// Field keys for address and location fields.
abstract class BfAddressKeys {
  static const fullAddress = 'fullAddress';
  static const addressLine1 = 'addressLine1';
  static const addressLine2 = 'addressLine2';
  static const street = 'street';
  static const streetNumber = 'streetNumber';
  static const apartment = 'apartment';
  static const unit = 'unit';
  static const suite = 'suite';
  static const floor = 'floor';
  static const building = 'building';

  static const city = 'city';
  static const state = 'state';
  static const province = 'province';
  static const region = 'region';
  static const county = 'county';
  static const district = 'district';

  static const zipCode = 'zipCode';
  static const postalCode = 'postalCode';
  static const postcode = 'postcode';

  static const country = 'country';
  static const countryCode = 'countryCode';

  static const latitude = 'latitude';
  static const longitude = 'longitude';
}

// ---------------------------------------------------------------------------
// Payment / Billing
// ---------------------------------------------------------------------------

/// Field keys for payment, billing, and financial fields.
abstract class BfPaymentKeys {
  static const cardNumber = 'cardNumber';
  static const cardholderName = 'cardholderName';
  static const expiryDate = 'expiryDate';
  static const expiryMonth = 'expiryMonth';
  static const expiryYear = 'expiryYear';
  static const cvv = 'cvv';
  static const cvc = 'cvc';

  static const bankName = 'bankName';
  static const accountNumber = 'accountNumber';
  static const routingNumber = 'routingNumber';
  static const iban = 'iban';
  static const swiftCode = 'swiftCode';
  static const sortCode = 'sortCode';

  static const amount = 'amount';
  static const currency = 'currency';
  static const price = 'price';
  static const discount = 'discount';
  static const discountCode = 'discountCode';
  static const couponCode = 'couponCode';
  static const promoCode = 'promoCode';
  static const taxId = 'taxId';
  static const vatNumber = 'vatNumber';

  static const billingAddress = 'billingAddress';
  static const billingCity = 'billingCity';
  static const billingState = 'billingState';
  static const billingZip = 'billingZip';
  static const billingCountry = 'billingCountry';
}

// ---------------------------------------------------------------------------
// Shipping / Delivery
// ---------------------------------------------------------------------------

/// Field keys for shipping and delivery fields.
abstract class BfShippingKeys {
  static const shippingMethod = 'shippingMethod';
  static const shippingAddress = 'shippingAddress';
  static const shippingCity = 'shippingCity';
  static const shippingState = 'shippingState';
  static const shippingZip = 'shippingZip';
  static const shippingCountry = 'shippingCountry';

  static const recipientName = 'recipientName';
  static const recipientPhone = 'recipientPhone';
  static const deliveryInstructions = 'deliveryInstructions';
  static const deliveryDate = 'deliveryDate';
  static const deliveryTime = 'deliveryTime';

  static const trackingNumber = 'trackingNumber';
  static const orderNotes = 'orderNotes';
}

// ---------------------------------------------------------------------------
// Company / Business
// ---------------------------------------------------------------------------

/// Field keys for company and business fields.
abstract class BfCompanyKeys {
  static const companyName = 'companyName';
  static const legalName = 'legalName';
  static const tradingName = 'tradingName';
  static const registrationNumber = 'registrationNumber';
  static const industry = 'industry';
  static const department = 'department';
  static const jobTitle = 'jobTitle';
  static const role = 'role';
  static const employeeId = 'employeeId';
  static const companySize = 'companySize';
  static const companyWebsite = 'companyWebsite';
  static const companyEmail = 'companyEmail';
  static const companyPhone = 'companyPhone';
}

// ---------------------------------------------------------------------------
// Social
// ---------------------------------------------------------------------------

/// Field keys for social media and online presence.
abstract class BfSocialKeys {
  static const x = 'x';
  static const facebook = 'facebook';
  static const instagram = 'instagram';
  static const linkedin = 'linkedin';
  static const github = 'github';
  static const youtube = 'youtube';
  static const tiktok = 'tiktok';
  static const discord = 'discord';
  static const slack = 'slack';
  static const telegram = 'telegram';
  static const whatsapp = 'whatsapp';
  static const skype = 'skype';
}

// ---------------------------------------------------------------------------
// Preferences / Settings
// ---------------------------------------------------------------------------

/// Field keys for user preferences, settings, and consent.
abstract class BfPreferenceKeys {
  static const theme = 'theme';
  static const darkMode = 'darkMode';
  static const notifications = 'notifications';
  static const emailNotifications = 'emailNotifications';
  static const pushNotifications = 'pushNotifications';
  static const smsNotifications = 'smsNotifications';
  static const newsletter = 'newsletter';

  static const termsAccepted = 'termsAccepted';
  static const privacyAccepted = 'privacyAccepted';
  static const marketingConsent = 'marketingConsent';
  static const cookieConsent = 'cookieConsent';
  static const ageVerification = 'ageVerification';

  static const rememberMe = 'rememberMe';
  static const twoFactorEnabled = 'twoFactorEnabled';
}

// ---------------------------------------------------------------------------
// Content / Feedback
// ---------------------------------------------------------------------------

/// Field keys for content creation, feedback, and reviews.
abstract class BfContentKeys {
  static const subject = 'subject';
  static const message = 'message';
  static const body = 'body';
  static const description = 'description';
  static const comment = 'comment';
  static const note = 'note';
  static const notes = 'notes';

  static const rating = 'rating';
  static const review = 'review';
  static const feedback = 'feedback';
  static const suggestion = 'suggestion';

  static const category = 'category';
  static const tags = 'tags';
  static const priority = 'priority';
  static const status = 'status';
  static const type = 'type';

  static const attachment = 'attachment';
  static const attachments = 'attachments';
  static const file = 'file';
  static const files = 'files';
  static const image = 'image';
  static const images = 'images';
  static const document = 'document';
  static const signature = 'signature';
}

// ---------------------------------------------------------------------------
// Date / Time
// ---------------------------------------------------------------------------

/// Field keys for date, time, and scheduling fields.
abstract class BfDateTimeKeys {
  static const date = 'date';
  static const time = 'time';
  static const dateTime = 'dateTime';
  static const startDate = 'startDate';
  static const endDate = 'endDate';
  static const startTime = 'startTime';
  static const endTime = 'endTime';
  static const dateRange = 'dateRange';
  static const duration = 'duration';
  static const frequency = 'frequency';
  static const deadline = 'deadline';
  static const reminder = 'reminder';
  static const appointmentDate = 'appointmentDate';
  static const appointmentTime = 'appointmentTime';
  static const checkIn = 'checkIn';
  static const checkOut = 'checkOut';
}

// ---------------------------------------------------------------------------
// Search / Filter
// ---------------------------------------------------------------------------

/// Field keys for search, filter, and query fields.
abstract class BfSearchKeys {
  static const query = 'query';
  static const search = 'search';
  static const keyword = 'keyword';
  static const filter = 'filter';
  static const sortBy = 'sortBy';
  static const sortOrder = 'sortOrder';
  static const minPrice = 'minPrice';
  static const maxPrice = 'maxPrice';
  static const minDate = 'minDate';
  static const maxDate = 'maxDate';
  static const pageSize = 'pageSize';
}
