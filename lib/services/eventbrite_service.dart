import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';
import '../utils/constants.dart';

class EventbriteService {
  static const String baseUrl = 'https://www.eventbriteapi.com/v3';
  final String? apiToken = AppConstants.eventbriteApiToken;

  // Get events from Eventbrite
  Future<List<EventModel>> getEventbriteEvents({
    String? location,
    String? categoryId,
    int page = 1,
  }) async {
    try {
      if (apiToken == null || apiToken!.isEmpty) {
        throw Exception('Eventbrite API token not configured');
      }

      Map<String, String> queryParams = {
        'token': apiToken!,
        'expand': 'venue,category',
        'page': page.toString(),
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location.address'] = location;
      }

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categories'] = categoryId;
      }

      Uri uri = Uri.parse('$baseUrl/events/search/').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['events'] as List;
        
        return events.map((eventData) => _convertEventbriteToEventModel(eventData)).toList();
      } else {
        throw Exception('Failed to fetch Eventbrite events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Eventbrite API error: ${e.toString()}');
    }
  }

  // Get event details from Eventbrite
  Future<EventModel?> getEventbriteEventDetails(String eventId) async {
    try {
      if (apiToken == null || apiToken!.isEmpty) {
        throw Exception('Eventbrite API token not configured');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/?expand=venue,category'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final eventData = json.decode(response.body);
        return _convertEventbriteToEventModel(eventData);
      } else {
        throw Exception('Failed to fetch event details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Eventbrite API error: ${e.toString()}');
    }
  }

  // Get Eventbrite categories
  Future<List<Map<String, dynamic>>> getEventbriteCategories() async {
    try {
      if (apiToken == null || apiToken!.isEmpty) {
        throw Exception('Eventbrite API token not configured');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/categories/'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['categories']);
      } else {
        throw Exception('Failed to fetch categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Eventbrite API error: ${e.toString()}');
    }
  }

  // Convert Eventbrite event data to EventModel
  EventModel _convertEventbriteToEventModel(Map<String, dynamic> eventData) {
    final venue = eventData['venue'];
    final category = eventData['category'];
    
    return EventModel(
      id: eventData['id'] ?? '',
      title: eventData['name']?['text'] ?? '',
      description: eventData['description']?['text'] ?? '',
      imageUrl: eventData['logo']?['url'] ?? '',
      startDate: DateTime.parse(eventData['start']?['utc'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(eventData['end']?['utc'] ?? DateTime.now().toIso8601String()),
      location: venue?['address']?['localized_area_display'] ?? '',
      latitude: double.tryParse(venue?['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(venue?['longitude']?.toString() ?? '0') ?? 0.0,
      categoryId: category?['id'] ?? '',
      organizerId: eventData['organizer_id'] ?? '',
      price: _extractPrice(eventData),
      maxAttendees: eventData['capacity'] ?? 0,
      currentAttendees: 0,
      createdAt: DateTime.parse(eventData['created'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(eventData['changed'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Extract price from Eventbrite event data
  double _extractPrice(Map<String, dynamic> eventData) {
    try {
      final ticketClasses = eventData['ticket_classes'] as List?;
      if (ticketClasses != null && ticketClasses.isNotEmpty) {
        final firstTicket = ticketClasses.first;
        final cost = firstTicket['cost'];
        if (cost != null) {
          return double.tryParse(cost['major_value']?.toString() ?? '0') ?? 0.0;
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Search events by keyword
  Future<List<EventModel>> searchEventbriteEvents(String query) async {
    try {
      if (apiToken == null || apiToken!.isEmpty) {
        throw Exception('Eventbrite API token not configured');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/events/search/?q=$query&expand=venue,category'),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['events'] as List;
        
        return events.map((eventData) => _convertEventbriteToEventModel(eventData)).toList();
      } else {
        throw Exception('Failed to search events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Eventbrite search error: ${e.toString()}');
    }
  }
}