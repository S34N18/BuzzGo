import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/category_model.dart';
import '../models/payment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String categoriesCollection = 'categories';
  static const String paymentsCollection = 'payments';

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection(usersCollection).doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _db.collection(usersCollection).doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _db.collection(usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Event operations
  Future<void> createEvent(EventModel event) async {
    try {
      await _db.collection(eventsCollection).doc(event.id).set(event.toJson());
    } catch (e) {
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  Future<EventModel?> getEvent(String eventId) async {
    try {
      DocumentSnapshot doc = await _db.collection(eventsCollection).doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event: ${e.toString()}');
    }
  }

  Future<List<EventModel>> getEvents({
    String? categoryId,
    String? organizerId,
    int limit = 20,
  }) async {
    try {
      Query query = _db.collection(eventsCollection).where('isActive', isEqualTo: true);
      
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      
      if (organizerId != null) {
        query = query.where('organizerId', isEqualTo: organizerId);
      }
      
      query = query.orderBy('startDate').limit(limit);
      
      QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events: ${e.toString()}');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _db.collection(eventsCollection).doc(event.id).update(event.toJson());
    } catch (e) {
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _db.collection(eventsCollection).doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }

  // Category operations
  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(categoriesCollection)
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get categories: ${e.toString()}');
    }
  }

  Future<void> createCategory(CategoryModel category) async {
    try {
      await _db.collection(categoriesCollection).doc(category.id).set(category.toJson());
    } catch (e) {
      throw Exception('Failed to create category: ${e.toString()}');
    }
  }

  // Payment operations
  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _db.collection(paymentsCollection).doc(payment.id).set(payment.toJson());
    } catch (e) {
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }

  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(paymentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PaymentModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user payments: ${e.toString()}');
    }
  }

  Future<void> updatePayment(PaymentModel payment) async {
    try {
      await _db.collection(paymentsCollection).doc(payment.id).update(payment.toJson());
    } catch (e) {
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }

  // Search events
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(eventsCollection)
          .where('isActive', isEqualTo: true)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .get();
      return snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: ${e.toString()}');
    }
  }

  // Get events by location (nearby events)
  Future<List<EventModel>> getNearbyEvents(
      double latitude, double longitude, double radiusInKm) async {
    try {
      // Note: For production, consider using GeoFlutterFire for better geospatial queries
      QuerySnapshot snapshot = await _db
          .collection(eventsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      List<EventModel> allEvents = snapshot.docs
          .map((doc) => EventModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Filter by distance (simplified calculation)
      return allEvents.where((event) {
        double distance = _calculateDistance(
          latitude, longitude, event.latitude, event.longitude);
        return distance <= radiusInKm;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get nearby events: ${e.toString()}');
    }
  }

  // Helper method to calculate distance between two points
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simplified distance calculation (Haversine formula would be more accurate)
    double deltaLat = lat2 - lat1;
    double deltaLon = lon2 - lon1;
    return (deltaLat * deltaLat + deltaLon * deltaLon) * 111; // Rough km conversion
  }
}