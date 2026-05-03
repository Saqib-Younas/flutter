/// Centralized validation logic for the entire application.
/// Single responsibility: Form field validation with consistent error messages.
class Validators {
  const Validators._();

  // ---- User Information Validators ----------------------------------------

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(value)) {
      return 'Enter a valid name (letters and spaces only)';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
      return 'Must contain at least one letter and one number';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a phone number';
    if (!RegExp(r'^[0-9\-\+\s()]{10,}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ---- Payment Validators -------------------------------------------------

  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number is required';
    final cleanValue = value.replaceAll(RegExp(r'\s'), '');
    if (cleanValue.length != 16) return 'Card number must be 16 digits';
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) {
      return 'Card number must contain only numbers';
    }
    return null;
  }

  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty)
      return 'Expiry date is required (MM/YY)';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
      return 'Use format MM/YY';
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'CVV is required';
    if (value.length < 3 || value.length > 4) {
      return 'CVV must be 3-4 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV must contain only numbers';
    }
    return null;
  }

  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) return 'Cardholder name is required';
    if (!RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(value)) {
      return 'Enter a valid cardholder name';
    }
    return null;
  }

  // ---- Address Validators -------------------------------------------------

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    if (value.length < 10) return 'Address must be at least 10 characters';
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) return 'City is required';
    if (!RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(value)) {
      return 'Enter a valid city name';
    }
    return null;
  }

  static String? validateZipCode(String? value) {
    if (value == null || value.isEmpty) return 'Zip code is required';
    if (!RegExp(r'^[0-9]{4,10}$').hasMatch(value)) {
      return 'Enter a valid zip code';
    }
    return null;
  }

  // ---- Generic Validators -------------------------------------------------

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(String? value, int min, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }

  static String? validateMaxLength(String? value, int max, String fieldName) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }
}
