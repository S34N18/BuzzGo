import 'package:flutter/foundation.dart';

// Simple logging utility using Flutter's built-in debugPrint
class _AppLogger {
  void info(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    }
  }
  
  void warning(String message) {
    if (kDebugMode) {
      debugPrint('[WARNING] $message');
    }
  }
  
  void error(String message) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
    }
  }
}

// Logger instance for the app
final _AppLogger _logger = _AppLogger();

class AppConfig {
  // App Information
  static const String appName = 'BuzzGo';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'Discover Local Events';
  static const String appPackageName = 'com.example.buzzgo';

  // Environment Configuration
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDebug => kDebugMode;

  // API Configuration
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.buzzgo.com';
      case 'staging':
        return 'https://staging-api.buzzgo.com';
      default:
        return 'https://dev-api.buzzgo.com';
    }
  }

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (environment) {
      case 'production':
        return 'buzzgo-prod';
      case 'staging':
        return 'buzzgo-staging';
      default:
        return 'buzzgo-dev';
    }
  }

  // Database Configuration
  static String get databaseUrl {
    return 'https://$firebaseProjectId-default-rtdb.firebaseio.com';
  }

  // Storage Configuration
  static String get storageBucket {
    return '$firebaseProjectId.appspot.com';
  }

  // Analytics Configuration
  static bool get enableAnalytics => isProduction;
  static bool get enableCrashlytics => isProduction;
  static bool get enablePerformanceMonitoring => isProduction;

  // Logging Configuration
  static bool get enableLogging => !isProduction;
  static bool get enableVerboseLogging => isDevelopment;

  // Feature Flags
  static bool get enableEventbriteIntegration => true;
  static bool get enableMpesaPayments => true;
  static bool get enablePushNotifications => true;
  static bool get enableOfflineMode => false;
  static bool get enableBiometricAuth => true;
  static bool get enableSocialLogin => true;
  static bool get enableLocationServices => true;
  static bool get enableImageUpload => true;
  static bool get enableVideoUpload => false;
  static bool get enableLiveStreaming => false;
  static bool get enableChatFeature => false;
  static bool get enableRatingSystem => true;
  static bool get enableRecommendations => true;

  // API Keys (These should be loaded from environment variables or secure storage)
  static String get googleMapsApiKey {
    return const String.fromEnvironment(
      'GOOGLE_MAPS_API_KEY',
      defaultValue: 'your-google-maps-api-key',
    );
  }

  static String get eventbriteApiKey {
    return const String.fromEnvironment(
      'EVENTBRITE_API_KEY',
      defaultValue: 'your-eventbrite-api-key',
    );
  }

  static String get mpesaConsumerKey {
    return const String.fromEnvironment(
      'MPESA_CONSUMER_KEY',
      defaultValue: 'your-mpesa-consumer-key',
    );
  }

  static String get mpesaConsumerSecret {
    return const String.fromEnvironment(
      'MPESA_CONSUMER_SECRET',
      defaultValue: 'your-mpesa-consumer-secret',
    );
  }

  // App Limits
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoUploadSize = 50 * 1024 * 1024; // 50MB
  static const int maxEventsPerUser = 100;
  static const int maxAttendeesPerEvent = 10000;
  static const int maxCategoriesPerEvent = 5;
  static const int maxImagesPerEvent = 10;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration imageCacheExpiration = Duration(days: 7);
  static const Duration userDataCacheExpiration = Duration(minutes: 30);

  // Network Configuration
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int eventsPerPage = 10;
  static const int usersPerPage = 15;
  static const int categoriesPerPage = 20;

  // Location Configuration
  static const double defaultLocationRadius = 10.0; // km
  static const double maxLocationRadius = 100.0; // km
  static const double defaultLatitude = -1.2921; // Nairobi
  static const double defaultLongitude = 36.8219; // Nairobi

  // Notification Configuration
  static const Duration notificationDelay = Duration(seconds: 1);
  static const int maxNotificationsPerDay = 10;
  static const Duration eventReminderTime = Duration(hours: 2);

  // Security Configuration
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration tokenRefreshInterval = Duration(minutes: 55);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Theme Configuration
  static const String defaultFontFamily = 'Roboto';
  static const double defaultFontSize = 14.0;
  static const double headingFontSize = 24.0;
  static const double titleFontSize = 18.0;

  // Social Media Configuration
  static const String facebookAppId = 'your-facebook-app-id';
  static const String twitterApiKey = 'your-twitter-api-key';
  static const String instagramClientId = 'your-instagram-client-id';

  // Deep Link Configuration
  static const String deepLinkScheme = 'buzzgo';
  static const String deepLinkHost = 'app.buzzgo.com';

  // App Store Configuration
  static const String androidAppId = 'com.example.buzzgo';
  static const String iosAppId = '123456789';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=$androidAppId';
  static const String appStoreUrl = 'https://apps.apple.com/app/id$iosAppId';

  // Support Configuration
  static const String supportEmail = 'support@buzzgo.com';
  static const String supportPhone = '+254700000000';
  static const String helpCenterUrl = 'https://help.buzzgo.com';
  static const String privacyPolicyUrl = 'https://buzzgo.com/privacy';
  static const String termsOfServiceUrl = 'https://buzzgo.com/terms';

  // Legal Configuration
  static const String companyName = 'BuzzGo Ltd';
  static const String companyAddress = 'Nairobi, Kenya';
  static const String copyrightText = '© 2025 BuzzGo Ltd. All rights reserved.';

  // Development Configuration
  static bool get showDebugBanner => isDevelopment;
  static bool get enableInspector => isDevelopment;
  static bool get enablePerformanceOverlay => isDevelopment && kDebugMode;

  // Testing Configuration
  static bool get enableTestMode => environment == 'test';
  static bool get mockApiCalls => enableTestMode;
  static bool get skipAuthentication => enableTestMode;

  // Accessibility Configuration
  static const bool enableAccessibilityFeatures = true;
  static const double minimumTouchTargetSize = 44.0;
  static const double textScaleFactor = 1.0;

  // Internationalization Configuration
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'sw']; // English, Swahili

  // Error Reporting Configuration
  static bool get enableErrorReporting => isProduction;
  static String get sentryDsn => const String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  // Performance Configuration
  static const int maxConcurrentRequests = 5;
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Backup Configuration
  static const Duration backupInterval = Duration(days: 1);
  static const int maxBackupFiles = 7;

  // Maintenance Configuration
  static bool get isMaintenanceMode => const bool.fromEnvironment('MAINTENANCE_MODE');
  static String get maintenanceMessage => const String.fromEnvironment(
    'MAINTENANCE_MESSAGE',
    defaultValue: 'The app is currently under maintenance. Please try again later.',
  );

  // Version Configuration
  static const String minimumSupportedVersion = '1.0.0';
  static const bool forceUpdate = false;

  // Helper methods
  static String getEnvironmentPrefix() {
    switch (environment) {
      case 'production':
        return '';
      case 'staging':
        return 'staging_';
      default:
        return 'dev_';
    }
  }

  static Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'environment': environment,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
      'isStaging': isStaging,
      'baseUrl': baseUrl,
      'firebaseProjectId': firebaseProjectId,
      'enableAnalytics': enableAnalytics,
      'enableLogging': enableLogging,
      'featureFlags': {
        'eventbriteIntegration': enableEventbriteIntegration,
        'mpesaPayments': enableMpesaPayments,
        'pushNotifications': enablePushNotifications,
        'offlineMode': enableOfflineMode,
        'biometricAuth': enableBiometricAuth,
        'socialLogin': enableSocialLogin,
        'locationServices': enableLocationServices,
      },
    };
  }

  static void printConfiguration() {
    if (enableLogging) {
      _logger.info('=== App Configuration ===');
      _logger.info('App Name: $appName');
      _logger.info('Version: $appVersion');
      _logger.info('Environment: $environment');
      _logger.info('Base URL: $baseUrl');
      _logger.info('Firebase Project: $firebaseProjectId');
      _logger.info('Debug Mode: $isDebug');
      _logger.info('Analytics Enabled: $enableAnalytics');
      _logger.info('Logging Enabled: $enableLogging');
      _logger.info('========================');
    }
  }
}