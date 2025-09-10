import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/eventbrite_service.dart';
import '../services/location_service.dart';

class EventProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final EventbriteService _eventbriteService = EventbriteService();
  final LocationService _locationService = LocationService();

  List<EventModel> _events = [];
  List<EventModel> _nearbyEvents = [];
  List<EventModel> _favoriteEvents = [];
  List<EventModel> _myEvents = [];
  List<CategoryModel> _categories = [];
  
  EventModel? _selectedEvent;
  CategoryModel? _selectedCategory;
  
  bool _isLoading = false;
  bool _isLoadingNearby = false;
  bool _isLoadingCategories = false;
  String? _errorMessage;
  
  String _searchQuery = '';
  double? _userLatitude;
  double? _userLongitude;

  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get nearbyEvents => _nearbyEvents;
  List<EventModel> get favoriteEvents => _favoriteEvents;
  List<EventModel> get myEvents => _myEvents;
  List<CategoryModel> get categories => _categories;
  
  EventModel? get selectedEvent => _selectedEvent;
  CategoryModel? get selectedCategory => _selectedCategory;
  
  bool get isLoading => _isLoading;
  bool get isLoadingNearby => _isLoadingNearby;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get errorMessage => _errorMessage;
  
  String get searchQuery => _searchQuery;
  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;

  // Load all events
  Future<void> loadEvents({String? categoryId, bool refresh = false}) async {
    try {
      if (refresh || _events.isEmpty) {
        _setLoading(true);
        _clearError();

        // Load events from Firestore
        List<EventModel> firestoreEvents = await _firestoreService.getEvents(
          categoryId: categoryId,
        );

        // Load events from Eventbrite (if configured)
        List<EventModel> eventbriteEvents = [];
        try {
          eventbriteEvents = await _eventbriteService.getEventbriteEvents(
            categoryId: categoryId,
          );
        } catch (e) {
          // Eventbrite integration is optional
          debugPrint('Eventbrite integration error: $e');
        }

        // Combine and sort events
        _events = [...firestoreEvents, ...eventbriteEvents];
        _events.sort((a, b) => a.startDate.compareTo(b.startDate));
      }
    } catch (e) {
      _setError('Failed to load events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load nearby events
  Future<void> loadNearbyEvents({double radiusInKm = 10.0}) async {
    try {
      _setLoadingNearby(true);
      _clearError();

      // Get user location if not available
      if (_userLatitude == null || _userLongitude == null) {
        await _updateUserLocation();
      }

      if (_userLatitude != null && _userLongitude != null) {
        _nearbyEvents = await _firestoreService.getNearbyEvents(
          _userLatitude!,
          _userLongitude!,
          radiusInKm,
        );
        _nearbyEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
      }
    } catch (e) {
      _setError('Failed to load nearby events: ${e.toString()}');
    } finally {
      _setLoadingNearby(false);
    }
  }

  // Load user's events (organized by user)
  Future<void> loadMyEvents(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _myEvents = await _firestoreService.getEvents(organizerId: userId);
      _myEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _setError('Failed to load my events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load favorite events
  Future<void> loadFavoriteEvents(List<String> favoriteEventIds) async {
    try {
      _setLoading(true);
      _clearError();

      _favoriteEvents = [];
      for (String eventId in favoriteEventIds) {
        EventModel? event = await _firestoreService.getEvent(eventId);
        if (event != null) {
          _favoriteEvents.add(event);
        }
      }
      _favoriteEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
    } catch (e) {
      _setError('Failed to load favorite events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _setLoadingCategories(true);
      _clearError();

      _categories = await _firestoreService.getCategories();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _setLoadingCategories(false);
    }
  }

  // Search events
  Future<void> searchEvents(String query) async {
    try {
      _setLoading(true);
      _clearError();
      _searchQuery = query;

      if (query.isEmpty) {
        await loadEvents(refresh: true);
        return;
      }

      // Search in Firestore
      List<EventModel> firestoreResults = await _firestoreService.searchEvents(query);

      // Search in Eventbrite
      List<EventModel> eventbriteResults = [];
      try {
        eventbriteResults = await _eventbriteService.searchEventbriteEvents(query);
      } catch (e) {
        debugPrint('Eventbrite search error: $e');
      }

      // Combine results
      _events = [...firestoreResults, ...eventbriteResults];
      _events.sort((a, b) => a.startDate.compareTo(b.startDate));
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Create event
  Future<bool> createEvent(EventModel event) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.createEvent(event);
      
      // Add to my events list
      _myEvents.insert(0, event);
      
      // Also add to main events list so it's visible to all users
      _events.insert(0, event);
      
      // Add to nearby events if location matches
      if (_userLatitude != null && _userLongitude != null) {
        double distance = _calculateDistance(
          _userLatitude!, _userLongitude!, 
          event.latitude, event.longitude
        );
        if (distance <= 10.0) { // Within 10km
          _nearbyEvents.insert(0, event);
        }
      }
      
      return true;
    } catch (e) {
      _setError('Failed to create event: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper method to calculate distance
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation
    double deltaLat = lat2 - lat1;
    double deltaLon = lon2 - lon1;
    return (deltaLat * deltaLat + deltaLon * deltaLon) * 111; // Rough km conversion
  }

  // Update event
  Future<bool> updateEvent(EventModel event) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateEvent(event);
      
      // Update in local lists
      _updateEventInLists(event);
      
      return true;
    } catch (e) {
      _setError('Failed to update event: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.deleteEvent(eventId);
      
      // Remove from local lists
      _removeEventFromLists(eventId);
      
      return true;
    } catch (e) {
      _setError('Failed to delete event: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set selected event
  void setSelectedEvent(EventModel? event) {
    _selectedEvent = event;
    notifyListeners();
  }

  // Set selected category
  void setSelectedCategory(CategoryModel? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Filter events by category
  void filterByCategory(String? categoryId) {
    _selectedCategory = categoryId != null 
        ? _categories.firstWhere((cat) => cat.id == categoryId)
        : null;
    loadEvents(categoryId: categoryId, refresh: true);
  }

  // Update user location
  Future<void> _updateUserLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      }
    } catch (e) {
      debugPrint('Failed to get user location: $e');
    }
  }

  // Update event in all lists
  void _updateEventInLists(EventModel updatedEvent) {
    // Update in events list
    int eventIndex = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (eventIndex != -1) {
      _events[eventIndex] = updatedEvent;
    }

    // Update in my events list
    int myEventIndex = _myEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (myEventIndex != -1) {
      _myEvents[myEventIndex] = updatedEvent;
    }

    // Update in nearby events list
    int nearbyIndex = _nearbyEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (nearbyIndex != -1) {
      _nearbyEvents[nearbyIndex] = updatedEvent;
    }

    // Update in favorite events list
    int favoriteIndex = _favoriteEvents.indexWhere((e) => e.id == updatedEvent.id);
    if (favoriteIndex != -1) {
      _favoriteEvents[favoriteIndex] = updatedEvent;
    }

    // Update selected event if it's the same
    if (_selectedEvent?.id == updatedEvent.id) {
      _selectedEvent = updatedEvent;
    }

    notifyListeners();
  }

  // Remove event from all lists
  void _removeEventFromLists(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    _myEvents.removeWhere((e) => e.id == eventId);
    _nearbyEvents.removeWhere((e) => e.id == eventId);
    _favoriteEvents.removeWhere((e) => e.id == eventId);

    if (_selectedEvent?.id == eventId) {
      _selectedEvent = null;
    }

    notifyListeners();
  }

  // Get events by date range
  List<EventModel> getEventsByDateRange(DateTime startDate, DateTime endDate) {
    return _events.where((event) {
      return event.startDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             event.startDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Get upcoming events
  List<EventModel> getUpcomingEvents({int limit = 10}) {
    DateTime now = DateTime.now();
    return _events
        .where((event) => event.startDate.isAfter(now))
        .take(limit)
        .toList();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingNearby(bool loading) {
    _isLoadingNearby = loading;
    notifyListeners();
  }

  void _setLoadingCategories(bool loading) {
    _isLoadingCategories = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  void clearSearch() {
    _searchQuery = '';
    loadEvents(refresh: true);
  }
}