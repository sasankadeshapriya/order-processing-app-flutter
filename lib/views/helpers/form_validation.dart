class FormValidator {
  static String? validateOrgName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter organization name';
    } else if (value.length < 2 || value.length > 50) {
      return 'Name must be between 2 and 50 characters';
    }
    return null;
  }

  static String? validateClientName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a client name';
    } else if (value.length < 2 || value.length > 50) {
      return 'Name must be between 2 and 50 characters';
    }
    return null;
  }

  // Validates business addresses
  static String? validateAddress(String? value) {
    if (value!.length < 10 || value.length > 100) {
      return 'Address must be between 10 and 100 characters';
    }
    return null;
  }

  static String? validateBusinessDetails(String? value) {
    if (value!.length < 10 || value.length > 200) {
      return 'Business details must be between 10 and 200 characters';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    final phoneRegExp = RegExp(r'^[0-9]{10}$');
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }
    // Phone number pattern validation

    else if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? taxID(String? value) {
    if (value!.length < 10 || value.length > 100) {
      return 'Address Tax Id between 2 and 10 characters';
    }
    return null;
  }

  static String? validateNic(String? value) {
  if (value == null || value.isEmpty) {
  return 'Please enter a NIC number';
  }

  // Regular expressions for NIC validation
  final nic9DigitWithLetterRegExp = RegExp(r'^\d{9}[Vv]?$');
  final nic12DigitRegExp = RegExp(r'^\d{12}$');

  // Validate 9-digit NIC with optional V/v
  if (value.length == 10 && !nic9DigitWithLetterRegExp.hasMatch(value)) {
  return 'NIC must be 9 digits followed by optional V/v';
  }

  // Validate 12-digit NIC
  if (value.length == 12 && !nic12DigitRegExp.hasMatch(value)) {
  return 'NIC must be exactly 12 digits';
  }

  // If neither of the conditions is met
  return 'Invalid NIC format';
  }



// static String? email(String? value) {
  //   final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter an email';
  //   } else if (!emailRegExp.hasMatch(value)) {
  //     return 'Please enter a valid email';
  //   }
  //   return null;
  // }

  // static String? password(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter a password';
  //   } else if (value.length < 6) {
  //     return 'Password must be at least 6 characters';
  //   }
  //   return null;
  // }

  // static String? nic(String? value) {
  //   final nicRegExp = RegExp(r'^[0-9]{9}[Vv]|[0-9]{12}$');
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter a NIC number';
  //   }
  //   // NIC pattern validation for both 9 and 12-digit NICs

  //   else if (!nicRegExp.hasMatch(value)) {
  //     return 'Please enter a valid NIC number';
  //   }

  //   // Check if all digits are the same for 9-digit NICs
  //   else if (value.length == 9 && value.runes.toSet().length == 2) {
  //     // All digits are the same and 'V'/'v' is present
  //     return 'Please enter a valid NIC number';
  //   }

  //   // Check if 12-digit NIC has 'V'/'v' at the end
  //   else if (value.length == 12 && value.endsWith('V') || value.endsWith('v')) {
  //     return 'Please enter a valid NIC number';
  //   }

  //   // Check if first two digits are within the range 01-50 for 9-digit NICs
  //   else if (value.length == 9 && int.parse(value.substring(0, 2)) <= 50) {
  //     return 'The birth year cannot exceed 50';
  //   }

  //   return null;
  // }

  // static String? validateEmail(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter your email';
  //   } else if (!value.contains('@')) {
  //     return 'Please enter a valid email';
  //   }
  //   return null;
  //}
}
