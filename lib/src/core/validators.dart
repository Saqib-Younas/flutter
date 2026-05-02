class Validators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z\s]{2,50}$').hasMatch(value)) {
      return 'Enter a valid name (letters only)';
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
}
