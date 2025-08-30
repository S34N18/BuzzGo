import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';
import '../models/user_model.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;

  // Cache keys
  static const String _eventsKey = 'cached_events';
  static const String _categoriesKey = 'cached_categories';
  static const String _userDataKey = 'cached_user_data';
  static const String _nearbyEventsKey = 'cached_nearby_events';
  static const String _favoriteEventsKey = 'cached_favorite_events';
  static const String _lastUpdateKey = 'last_update_';

  // Cache expiration times
  static const Duration _eventsCacheExpiration = Duration(minutes: 15);
  static const Duration _categoriesCacheExpiration = Duration(hours: 1);
  static const Duration _userDataCacheExpiration = Duration(minutes: 30);

  // Initialize cache service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Generic cache methods
  Future<void> _setString(String key, String value) async {
    await _prefs?.setString(key, value);
    await _setLastUpdate(key);
  }

  String? _getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> _setLastUpdate(String key) async {
    await _prefs?.setString(
      '$_lastUpdateKey$key',
      DateTime.now().toIso8601String(),
    );
  }

  DateTime? _getLastUpdate(String key) {
    final updateString = _prefs?.getString('$_lastUpdateKey$key');
    if (updateString != null) {
      return DateTime.tryParse(updateString);
    }
    return null;
  }

  bool _isCacheExpired(String key, Duration expiration) {
    final lastUpdate = _getLastUpdate(key);
    if (lastUpdate == null) return true;
    
    return DateTime.now().difference(lastUpdate) > expiration;
  }

  // Events cache
  Future<void> cacheEvents(List<EventModel> events) async {
    final eventsJson = events.map((event) => event.toJson()).toList();
    await _setString(_eventsKey, json.encode(eventsJson));
  }

  List<EventModel>? getCachedEvents() {
    if (_isCacheExpired(_eventsKey, _eventsCacheExpiration)) {
      return null;
    }

    final eventsString = _getString(_eventsKey);
    if (eventsString != null) {
      try {
        final List<dynamic> eventsJson = json.decode(eventsString);
        return eventsJson.map((json) => EventModel.fromJson(json)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Categories cache
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final categoriesJson = categories.map((category) => category.toJson()).toList();
    await _setString(_categoriesKey, json.encode(categoriesJson));
  }

  List<CategoryModel>? getCachedCategories() {
    if (_isCacheExpired(_categoriesKey, _categoriesCacheExpiration)) {
      return null;
    }

    final categoriesString = _getString(_categoriesKey);
    if (categoriesString != null) {
      try {
        final List<dynamic> categoriesJson = json.decode(categoriesString);
        return categoriesJson.map((json) => CategoryModel.fromJson(json)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // User data cache
  Future<void> cacheUserData(UserModel user) async {
    await _setString(_userDataKey, json.encode(user.toJson()));
  }

  UserModel? getCachedUserData() {
    if (_isCacheExpired(_userDataKey, _userDataCacheExpiration)) {
      return null;
    }

    final userString = _getString(_userDataKey);
    if (userString != null) {
      try {
        final Map<String, dynamic> userJson = json.decode(userString);
        return UserModel.fromJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Nearby events cache
  Future<void> cacheNearbyEvents(List<EventModel> events, double lat, double lng) async {
    final data = {
      'events': events.map((event) => event.toJson()).toList(),
      'latitude': lat,
      'longitude': lng,
    };
    await _setString(_nearbyEventsKey, json.encode(data));
  }

  List<EventModel>? getCachedNearbyEvents(double lat, double lng, {double tolerance = 0.01}) {
    if (_isCacheExpired(_nearbyEventsKey, _eventsCacheExpiration)) {
      return null;
    }

    final dataString = _getString(_nearbyEventsKey);
    if (dataString != null) {
      try {
        final Map<String, dynamic> data = json.decode(dataString);
        final cachedLat = data['latitude'] as double;
        final cachedLng = data['longitude'] as double;
        
        // Check if location is within tolerance
        if ((cachedLat - lat).abs() <= tolerance && (cachedLng - lng).abs() <= tolerance) {
          final List<dynamic> eventsJson = data['events'];
          return eventsJson.map((json) => EventModel.fromJson(json)).toList();
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Favorite events cache
  Future<void> cacheFavoriteEvents(List<EventModel> events) async {
    final eventsJson = events.map((event) => event.toJson()).toList();
    await _setString(_favoriteEventsKey, json.encode(eventsJson));
  }

  List<EventModel>? getCachedFavoriteEvents() {
    final eventsString = _getString(_favoriteEventsKey);
    if (eventsString != null) {
      try {
        final List<dynamic> eventsJson = json.decode(eventsString);
        return eventsJson.map((json) => EventModel.fromJson(json)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Search cache
  Future<void> cacheSearchResults(String query, List<EventModel> results) async {
    final searchKey = 'search_$query';
    final resultsJson = results.map((event) => event.toJson()).toList();
    await _setString(searchKey, json.encode(resultsJson));
  }

  List<EventModel>? getCachedSearchResults(String query) {
    final searchKey = 'search_$query';
    if (_isCacheExpired(searchKey, const Duration(minutes: 10))) {
      return null;
    }

    final resultsString = _getString(searchKey);
    if (resultsString != null) {
      try {
        final List<dynamic> resultsJson = json.decode(resultsString);
        return resultsJson.map((json) => EventModel.fromJson(json)).toList();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // User preferences cache
  Future<void> cacheUserPreferences(Map<String, dynamic> preferences) async {
    await _setString('user_preferences', json.encode(preferences));
  }

  Map<String, dynamic>? getCachedUserPreferences() {
    final prefsString = _getString('user_preferences');
    if (prefsString != null) {
      try {
        return json.decode(prefsString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Clear specific cache
  Future<void> clearEventsCache() async {
    await _prefs?.remove(_eventsKey);
    await _prefs?.remove('$_lastUpdateKey$_eventsKey');
  }

  Future<void> clearCategoriesCache() async {
    await _prefs?.remove(_categoriesKey);
    await _prefs?.remove('$_lastUpdateKey$_categoriesKey');
  }

  Future<void> clearUserDataCache() async {
    await _prefs?.remove(_userDataKey);
    await _prefs?.remove('$_lastUpdateKey$_userDataKey');
  }

  Future<void> clearNearbyEventsCache() async {
    await _prefs?.remove(_nearbyEventsKey);
    await _prefs?.remove('$_lastUpdateKey$_nearbyEventsKey');
  }

  Future<void> clearSearchCache() async {
    final keys = _prefs?.getKeys().where((key) => key.startsWith('search_')) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
      await _prefs?.remove('$_lastUpdateKey$key');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await clearEventsCache();
    await clearCategoriesCache();
    await clearUserDataCache();
    await clearNearbyEventsCache();
    await clearSearchCache();
  }

  // Cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    final keys = _prefs?.getKeys() ?? <String>{};
    final cacheKeys = keys.where((key) => !key.startsWith(_lastUpdateKey)).toList();
    
    int totalSize = 0;
    for (final key in cacheKeys) {
      final value = _prefs?.getString(key) ?? '';
      totalSize += value.length;
    }

    return {
      'totalItems': cacheKeys.length,
      'totalSizeBytes': totalSize,
      'totalSizeKB': (totalSize / 1024).toStringAsFixed(2),
      'lastCleared': _prefs?.getString('last_cache_clear'),
    };
  }

  // Set cache clear timestamp
  Future<void> setCacheClearTimestamp() async {
    await _prefs?.setString('last_cache_clear', DateTime.now().toIso8601String());
  }
}