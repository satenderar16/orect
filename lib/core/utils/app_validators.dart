class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null; // valid
  }
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    List<String> errors = [];

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      errors.add('must contain a number');
    }

    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      errors.add('must contain a special character');
    }

    if (value.length < 8) {
      errors.add('Must be at least 8 characters');
    }

    if (errors.isEmpty) return null;

    return errors.join('\n');
  }
static  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be exactly 6 digits';
    }

    return null; // valid
  }
 static String? validatePhoneNumber(String? val) {
    if (val == null || val.isEmpty) return 'Required';
    if (val.length != 10) return 'Phone number must be 10 digits';
    return null;
  }

 static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  static String? validateAddress(val) {
    if (val == null || val.trim().isEmpty) {
    return 'Required';
    }
    if (val.trim().length < 5) return 'Address too short';
    return null;
    }




// You can add more validators here like password, phone, etc.
}