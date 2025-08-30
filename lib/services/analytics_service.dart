import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // User Events
  Future<void> logUserSignUp(String method) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logUserLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> setUserProperties(UserModel user) async {
    try {
      await _analytics.setUserId(id: user.id);
      await _analytics.setUserProperty(
        name: 'user_type',
        value: user.isAdmin ? 'admin' : 'regular',
      );
      await _analytics.setUserProperty(
        name: 'registration_date',
        value: user.createdAt.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Event Analytics
  Future<void> logEventView(EventModel event) async {
    try {
      await _analytics.logEvent(
        name: 'view_event',
        parameters: {
          'event_id': event.id,
          'event_title': event.title,
          'event_category': event.categoryId,
          'event_price': event.price,
          'event_location': event.location,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logEventSearch(String query, int resultsCount) async {
    try {
      await _analytics.logSearch(
        searchTerm: query,
        numberOfHits: resultsCount,
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logEventShare(EventModel event, String method) async {
    try {
      await _analytics.logShare(
        contentType: 'event',
        itemId: event.id,
        method: method,
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logEventFavorite(EventModel event, bool isFavorited) async {
    try {
      await _analytics.logEvent(
        name: isFavorited ? 'add_to_favorites' : 'remove_from_favorites',
        parameters: {
          'event_id': event.id,
          'event_title': event.title,
          'event_category': event.categoryId,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logEventRegistration(EventModel event) async {
    try {
      await _analytics.logEvent(
        name: 'event_registration',
        parameters: {
          'event_id': event.id,
          'event_title': event.title,
          'event_category': event.categoryId,
          'event_price': event.price,
          'registration_type': event.price > 0 ? 'paid' : 'free',
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logEventCreation(EventModel event) async {
    try {
      await _analytics.logEvent(
        name: 'create_event',
        parameters: {
          'event_category': event.categoryId,
          'event_price': event.price,
          'max_attendees': event.maxAttendees,
          'is_paid': event.price > 0,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // App Usage Analytics
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logLocationPermission(bool granted) async {
    try {
      await _analytics.logEvent(
        name: 'location_permission',
        parameters: {
          'granted': granted,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logNotificationPermission(bool granted) async {
    try {
      await _analytics.logEvent(
        name: 'notification_permission',
        parameters: {
          'granted': granted,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Filter and Search Analytics
  Future<void> logCategoryFilter(String categoryId, String categoryName) async {
    try {
      await _analytics.logEvent(
        name: 'filter_by_category',
        parameters: {
          'category_id': categoryId,
          'category_name': categoryName,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logLocationFilter(double latitude, double longitude, double radius) async {
    try {
      await _analytics.logEvent(
        name: 'filter_by_location',
        parameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radius,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> logPriceFilter(double minPrice, double maxPrice) async {
    try {
      await _analytics.logEvent(
        name: 'filter_by_price',
        parameters: {
          'min_price': minPrice,
          'max_price': maxPrice,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Error Analytics
  Future<void> logError(String errorType, String errorMessage, {String? screen}) async {
    try {
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (screen != null) 'screen': screen,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Performance Analytics
  Future<void> logPerformanceMetric(String metricName, double value) async {
    try {
      await _analytics.logEvent(
        name: 'performance_metric',
        parameters: {
          'metric_name': metricName,
          'value': value,
        },
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Custom Events
  Future<void> logCustomEvent(String eventName, Map<String, Object> parameters) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Set custom user properties
  Future<void> setCustomUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  // Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }
}