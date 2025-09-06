# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

BuzzGo is a Flutter-based local event finder mobile application that allows users to discover, create, and manage events in their area. The app integrates with Firebase for backend services and includes features like user authentication, event management, payment processing (M-Pesa), location services, and admin functionality.

## Development Commands

### Setup and Dependencies
```bash
# Get all dependencies
flutter pub get

# Clean build cache
flutter clean && flutter pub get

# Generate platform-specific files (if needed)
flutter pub run
```

### Building and Running
```bash
# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>

# Build APK for Android
flutter build apk

# Build app bundle for Play Store
flutter build appbundle

# Build for iOS (macOS only)
flutter build ios
```

### Testing and Quality Assurance
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Analyze code for issues
flutter analyze

# Format code
dart format lib/ test/

# Check for outdated dependencies
flutter pub deps
```

### Firebase Integration
```bash
# Configure Firebase (run once per platform)
flutterfire configure

# Generate Firebase options
flutter pub run firebase_cli:generate
```

## Code Architecture

### State Management
- **Pattern**: Provider pattern with ChangeNotifier
- **Key Providers**: 
  - `AuthProvider`: User authentication and session management
  - `EventProvider`: Event data management and CRUD operations
  - `UserProvider`: User profile and preferences
  - `ThemeProvider`: App theming and appearance

### Project Structure
```
lib/
├── config/           # App configuration and Firebase setup
├── models/           # Data models (Event, User, Category, Payment)
├── providers/        # State management providers
├── screens/          # UI screens organized by feature
│   ├── auth/         # Authentication screens
│   ├── events/       # Event-related screens
│   ├── admin/        # Admin dashboard and management
│   └── payment/      # Payment and billing screens
├── services/         # Business logic and API integrations
├── utils/            # Utilities, constants, and helpers
└── widgets/          # Reusable UI components
```

### Core Services
- **FirestoreService**: Primary database operations with Firestore
- **AuthService**: Firebase Authentication integration
- **LocationService**: GPS and location-based features using Geolocator
- **MPesaService**: Mobile payment integration
- **EventbriteService**: External event data integration
- **NotificationService**: Push notifications and local alerts
- **CacheService**: Data caching and offline support

### Data Flow
1. UI screens consume data through Provider widgets
2. Providers coordinate between services and manage state
3. Services handle external API calls and data persistence
4. Models define data structure and JSON serialization

### Environment Configuration
- **AppConfig**: Centralized configuration with environment-specific settings
- **Feature Flags**: Toggle functionality based on environment
- **API Endpoints**: Environment-specific URLs for development/staging/production

## Key Dependencies

### Core Flutter & Firebase
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `firebase_messaging`, `firebase_analytics`

### State & Data Management
- `provider` for state management
- `shared_preferences` for local storage
- `connectivity_plus` for network monitoring

### Location & Maps
- `geolocator` and `geocoding` for location services
- `google_maps_flutter` for map integration

### Payment & External APIs
- `mpesa_flutter_plugin` for mobile payments
- `dio` and `http` for API communication

### UI & UX
- `flutter_local_notifications` for notifications
- `image_picker` for media handling
- `url_launcher` for external links

## Development Guidelines

### Naming Conventions
- Files: Use snake_case (e.g., `event_list_screen.dart`)
- Classes: Use PascalCase (e.g., `EventProvider`)
- Variables/functions: Use camelCase (e.g., `loadEvents()`)
- Constants: Use SCREAMING_SNAKE_CASE (e.g., `MAX_ATTENDEES`)

### Error Handling
- Services should throw exceptions with descriptive messages
- Providers should catch and handle service exceptions
- UI should display user-friendly error messages
- Use try-catch blocks consistently across async operations

### Testing Approach
- Widget tests for UI components
- Unit tests for business logic in services and providers
- Mock external dependencies (Firebase, APIs) in tests
- Test both success and error scenarios

### Environment Management
- Use `--dart-define` for environment-specific values
- Keep API keys in environment variables, not hardcoded
- Configure different Firebase projects for dev/staging/prod

### Location & Permission Handling
- Always check location permissions before accessing GPS
- Provide fallback behavior when location is unavailable
- Handle location services being disabled gracefully

### Firebase Security
- Implement proper Firestore security rules
- Use Firebase App Check for API protection
- Never expose sensitive configuration in client code

## Common Development Patterns

### Loading States
```dart
// Consistent loading state pattern in providers
_setLoading(true);
try {
  // Async operation
} catch (e) {
  _setError(e.toString());
} finally {
  _setLoading(false);
}
```

### Navigation
- Use `AppRoutes` class for centralized route management
- Implement route guards for authentication-required screens
- Pass data between screens using route arguments

### Data Fetching
- Combine Firestore and external API data in providers
- Implement proper pagination for large datasets
- Use caching to reduce network requests

### Authentication Flow
- Check authentication state in splash screen
- Redirect to login if user is not authenticated
- Implement proper session management and token refresh
