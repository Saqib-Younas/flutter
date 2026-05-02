class PaymentValidators {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Card number dalein';
    String cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length != 16) return '16 digits ka number hona chahiye';
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanValue)) return 'Sirf numbers dalein';
    return null;
  }

  static String? validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Expiry dalein (MM/YY)';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$').hasMatch(value)) {
      return 'Sahi format MM/YY dalein';
    }
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'CVV dalein';
    if (value.length < 3) return 'CVV kam az kam 3 digits ka ho';
    return null;
  }
}
