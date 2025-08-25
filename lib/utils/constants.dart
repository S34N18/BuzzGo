class AppConstants {
  // App Information
  static const String appName = 'BuzzGo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Discover Local Events';

  // API Configuration
  static const bool isProduction = false; // Set to true for production
  
  // Firebase Configuration (These will be set in firebase_config.dart)
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String firebaseApiKey = 'your-firebase-api-key';
  static const String firebaseAppId = 'your-firebase-app-id';
  
  // Eventbrite API Configuration
  static const String eventbriteApiToken = 'your-eventbrite-api-token';
  static const String eventbriteOrganizationId = 'your-eventbrite-organization-id';
  
  // M-Pesa Configuration
  static const String mpesaConsumerKey = 'your-mpesa-consumer-key';
  static const String mpesaConsumerSecret = 'your-mpesa-consumer-secret';
  static const String mpesaShortCode = 'your-mpesa-shortcode';
  static const String mpesaPasskey = 'your-mpesa-passkey';
  static const String mpesaCallbackUrl = 'https://your-domain.com/mpesa/callback';
  
  // Google Maps Configuration
  static const String googleMapsApiKey = 'your-google-maps-api-key';
  
  // Default Values
  static const int defaultEventLimit = 20;
  static const double defaultLocationRadius = 10.0; // km
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination
  static const int eventsPerPage = 10;
  static const int categoriesPerPage = 20;
  static const int usersPerPage = 15;
  
  // Cache Duration
  static const Duration cacheEventsDuration = Duration(minutes: 15);
  static const Duration cacheCategoriesDuration = Duration(hours: 1);
  static const Duration cacheUserDataDuration = Duration(minutes: 30);
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Text Limits
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 1000;
  static const int maxUserNameLength = 50;
  static const int maxLocationLength = 200;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ssZ';
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String noDataMessage = 'No data available.';
  static const String noEventsMessage = 'No events found.';
  static const String noFavoritesMessage = 'No favorite events yet.';
  
  // Success Messages
  static const String eventCreatedMessage = 'Event created successfully!';
  static const String eventUpdatedMessage = 'Event updated successfully!';
  static const String eventDeletedMessage = 'Event deleted successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String paymentSuccessMessage = 'Payment completed successfully!';
  
  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidEmailMessage = 'Please enter a valid email address';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String passwordTooShortMessage = 'Password must be at least 6 characters';
  static const String passwordMismatchMessage = 'Passwords do not match';
  static const String invalidDateMessage = 'Please select a valid date';
  static const String invalidPriceMessage = 'Please enter a valid price';
  
  // Event Categories (Default)
  static const List<Map<String, String>> defaultCategories = [
    {'name': 'Music', 'color': '#FF6B6B', 'icon': 'music_note'},
    {'name': 'Sports', 'color': '#4ECDC4', 'icon': 'sports'},
    {'name': 'Food', 'color': '#45B7D1', 'icon': 'restaurant'},
    {'name': 'Art', 'color': '#96CEB4', 'icon': 'palette'},
    {'name': 'Technology', 'color': '#FFEAA7', 'icon': 'computer'},
    {'name': 'Business', 'color': '#DDA0DD', 'icon': 'business'},
    {'name': 'Education', 'color': '#98D8C8', 'icon': 'school'},
    {'name': 'Health', 'color': '#F7DC6F', 'icon': 'health_and_safety'},
    {'name': 'Entertainment', 'color': '#BB8FCE', 'icon': 'movie'},
    {'name': 'Travel', 'color': '#85C1E9', 'icon': 'travel_explore'},
  ];
  
  // Payment Methods
  static const List<String> paymentMethods = [
    'M-Pesa',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
  ];
  
  // Event Status
  static const List<String> eventStatuses = [
    'Draft',
    'Published',
    'Cancelled',
    'Completed',
  ];
  
  // User Roles
  static const String userRole = 'user';
  static const String adminRole = 'admin';
  static const String organizerRole = 'organizer';
  
  // Storage Keys (for SharedPreferences)
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String onboardingKey = 'onboarding_completed';
  static const String notificationsKey = 'notifications_enabled';
  static const String locationKey = 'location_enabled';
  
  // Notification Types
  static const String eventReminderNotification = 'event_reminder';
  static const String newEventNotification = 'new_event';
  static const String paymentNotification = 'payment_status';
  static const String generalNotification = 'general';
  
  // Social Media Links
  static const String facebookUrl = 'https://facebook.com/buzzgo';
  static const String twitterUrl = 'https://twitter.com/buzzgo';
  static const String instagramUrl = 'https://instagram.com/buzzgo';
  static const String linkedinUrl = 'https://linkedin.com/company/buzzgo';
  
  // Support Information
  static const String supportEmail = 'support@buzzgo.com';
  static const String supportPhone = '+254700000000';
  static const String privacyPolicyUrl = 'https://buzzgo.com/privacy';
  static const String termsOfServiceUrl = 'https://buzzgo.com/terms';
  
  // Location Defaults (Nairobi, Kenya)
  static const double defaultLatitude = -1.2921;
  static const double defaultLongitude = 36.8219;
  static const String defaultCity = 'Nairobi';
  static const String defaultCountry = 'Kenya';
  
  // Image Placeholders
  static const String defaultEventImage = 'https://via.placeholder.com/400x200?text=Event';
  static const String defaultUserAvatar = 'https://via.placeholder.com/100x100?text=User';
  static const String defaultCategoryIcon = 'https://via.placeholder.com/50x50?text=Category';
  
  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^(\+254|0)[17]\d{8}$'; // Kenyan phone numbers
  static const String urlRegex = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
  
  // Feature Flags
  static const bool enableEventbriteIntegration = true;
  static const bool enableMpesaPayments = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableOfflineMode = false;
  
  // Debug Settings
  static const bool enableDebugMode = !isProduction;
  static const bool enableLogging = !isProduction;
  static const bool enablePerformanceMonitoring = isProduction;
}