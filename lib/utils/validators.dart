import 'constants.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    final emailRegExp = RegExp(AppConstants.emailRegex);
    if (!emailRegExp.hasMatch(value)) {
      return AppConstants.invalidEmailMessage;
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    if (value.length < 6) {
      return AppConstants.passwordTooShortMessage;
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    if (value != password) {
      return AppConstants.passwordMismatchMessage;
    }
    
    return null;
  }

  // Phone number validation (Kenyan format)
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.requiredFieldMessage;
    }
    
    // Remove spaces and special characters
    String cleanNumber = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    final phoneRegExp = RegExp(AppConstants.phoneRegex);
    if (!phoneRegExp.hasMatch(cleanNumber)) {
      return AppConstants.invalidPhoneMessage;
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null 
          ? '$fieldName is required'
          : AppConstants.requiredFieldMessage;
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    if (value.trim().length > AppConstants.maxUserNameLength) {
      return 'Name must be less than ${AppConstants.maxUserNameLength} characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegExp = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Event title validation
  static String? validateEventTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Event title is required';
    }
    
    if (value.trim().length < 3) {
      return 'Event title must be at least 3 characters';
    }
    
    if (value.trim().length > AppConstants.maxEventTitleLength) {
      return 'Event title must be less than ${AppConstants.maxEventTitleLength} characters';
    }
    
    return null;
  }

  // Event description validation
  static String? validateEventDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Event description is required';
    }
    
    if (value.trim().length < 10) {
      return 'Event description must be at least 10 characters';
    }
    
    if (value.trim().length > AppConstants.maxEventDescriptionLength) {
      return 'Event description must be less than ${AppConstants.maxEventDescriptionLength} characters';
    }
    
    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    
    if (value.trim().length < 3) {
      return 'Location must be at least 3 characters';
    }
    
    if (value.trim().length > AppConstants.maxLocationLength) {
      return 'Location must be less than ${AppConstants.maxLocationLength} characters';
    }
    
    return null;
  }

  // Price validation
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Price is optional (can be free)
    }
    
    final double? price = double.tryParse(value);
    if (price == null) {
      return AppConstants.invalidPriceMessage;
    }
    
    if (price < 0) {
      return 'Price cannot be negative';
    }
    
    if (price > 1000000) {
      return 'Price cannot exceed 1,000,000';
    }
    
    return null;
  }

  // Max attendees validation
  static String? validateMaxAttendees(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Maximum attendees is required';
    }
    
    final int? maxAttendees = int.tryParse(value);
    if (maxAttendees == null) {
      return 'Please enter a valid number';
    }
    
    if (maxAttendees < 1) {
      return 'Maximum attendees must be at least 1';
    }
    
    if (maxAttendees > 100000) {
      return 'Maximum attendees cannot exceed 100,000';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return AppConstants.invalidDateMessage;
    }
    
    return null;
  }

  // Future date validation
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return AppConstants.invalidDateMessage;
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    
    return null;
  }

  // End date validation (must be after start date)
  static String? validateEndDate(DateTime? endDate, DateTime? startDate) {
    if (endDate == null) {
      return AppConstants.invalidDateMessage;
    }
    
    if (startDate != null && endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegExp = RegExp(AppConstants.urlRegex);
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Image URL validation
  static String? validateImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Image URL is optional
    }
    
    final urlRegExp = RegExp(AppConstants.urlRegex);
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid image URL';
    }
    
    // Check if URL ends with image extension
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final hasImageExtension = imageExtensions.any(
      (ext) => value.toLowerCase().endsWith('.$ext'),
    );
    
    if (!hasImageExtension) {
      return 'URL must point to an image file (jpg, jpeg, png, gif, webp)';
    }
    
    return null;
  }

  // Age validation (for age-restricted events)
  static String? validateAge(String? value, {int minAge = 0, int maxAge = 120}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Age is optional
    }
    
    final int? age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < minAge) {
      return 'Age must be at least $minAge';
    }
    
    if (age > maxAge) {
      return 'Age cannot exceed $maxAge';
    }
    
    return null;
  }

  // Credit card number validation (basic)
  static String? validateCreditCard(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credit card number is required';
    }
    
    // Remove spaces and hyphens
    String cleanNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Credit card number can only contain digits';
    }
    
    // Check length (most cards are 13-19 digits)
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Credit card number must be 13-19 digits';
    }
    
    // Luhn algorithm validation
    if (!_isValidLuhn(cleanNumber)) {
      return 'Invalid credit card number';
    }
    
    return null;
  }

  // CVV validation
  static String? validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV is required';
    }
    
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }
    
    return null;
  }

  // Expiry date validation (MM/YY format)
  static String? validateExpiryDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }
    
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }
    
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    
    if (month == null || year == null) {
      return 'Invalid expiry date';
    }
    
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;
    
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    
    return null;
  }

  // Luhn algorithm for credit card validation
  static bool _isValidLuhn(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    return sum % 10 == 0;
  }

  // Search query validation
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a search term';
    }
    
    if (value.trim().length < 2) {
      return 'Search term must be at least 2 characters';
    }
    
    if (value.trim().length > 100) {
      return 'Search term must be less than 100 characters';
    }
    
    return null;
  }

  // Feedback/Review validation
  static String? validateFeedback(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Feedback is required';
    }
    
    if (value.trim().length < 10) {
      return 'Feedback must be at least 10 characters';
    }
    
    if (value.trim().length > 500) {
      return 'Feedback must be less than 500 characters';
    }
    
    return null;
  }

  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Please provide a rating';
    }
    
    if (value < 1 || value > 5) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }
}