// Debug script to check event creation and visibility issues
// Run with: dart debug_events.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
final logger = Logger();

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  logger.i('🔍 Debugging Event Creation and Visibility Issues');
  logger.i('================================================');
  
  // Get current user
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    logger.i('❌ No user is currently logged in');
    return;
  }
  
  logger.i('📧 Current User: ${currentUser.email}');
  logger.i('🆔 User ID: ${currentUser.uid}');
  logger.i('');
  
  // Check if user is admin
  await checkAdminStatus(currentUser.uid);
  
  // Check events collection
  await checkEventsCollection();
  
  // Check events created by current user
  await checkUserEvents(currentUser.uid);
  
  // Check specific event by ID (if provided)
  // await checkSpecificEvent('event-id-here');
}

Future<void> checkAdminStatus(String userId) async {
  logger.i('🔍 Checking Admin Status...');
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      bool isAdmin = userData['isAdmin'] ?? false;
      logger.i('   ✅ User found in Firestore');
      logger.i('   👑 Admin Status: $isAdmin');
    } else {
      logger.i('   ❌ User document not found in Firestore');
      logger.i('   ⚠️  This could prevent event creation');
    }
  } catch (e) {
    logger.i('   ❌ Error checking admin status: $e');
  }
  logger.i('');
}

Future<void> checkEventsCollection() async {
  logger.i('🔍 Checking Events Collection...');
  try {
    // Get all events
    QuerySnapshot allEventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .get();
    
    logger.i('   📊 Total events in database: ${allEventsSnapshot.docs.length}');
    
    if (allEventsSnapshot.docs.isEmpty) {
      logger.i('   ⚠️  No events found in the database');
      logger.i('   💡 This could mean events aren\'t being created properly');
      return;
    }
    
    // Check active events (what users should see)
    QuerySnapshot activeEventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('isActive', isEqualTo: true)
        .get();
    
    logger.i('   ✅ Active events (visible to users): ${activeEventsSnapshot.docs.length}');
    
    // Check inactive events
    int inactiveCount = allEventsSnapshot.docs.length - activeEventsSnapshot.docs.length;
    if (inactiveCount > 0) {
      logger.i('   🚫 Inactive events (hidden from users): $inactiveCount');
    }
    
    // Show recent events
    QuerySnapshot recentEvents = await FirebaseFirestore.instance
        .collection('events')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    
    logger.i('   📅 Recent events:');
    for (var doc in recentEvents.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String title = data['title'] ?? 'No title';
      bool isActive = data['isActive'] ?? false;
      String organizer = data['organizerId'] ?? 'Unknown';
      String created = data['createdAt'] ?? 'Unknown';
      
      logger.i('      - "$title" (${isActive ? "ACTIVE" : "INACTIVE"}) by $organizer at $created');
    }
    
  } catch (e) {
    logger.i('   ❌ Error checking events: $e');
  }
  logger.i('');
}

Future<void> checkUserEvents(String userId) async {
  logger.i('🔍 Checking Events Created by Current User...');
  try {
    QuerySnapshot userEventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('organizerId', isEqualTo: userId)
        .get();
    
    logger.i('   📊 Events created by you: ${userEventsSnapshot.docs.length}');
    
    if (userEventsSnapshot.docs.isEmpty) {
      logger.i('   ⚠️  No events found created by your user ID');
      logger.i('   💡 Try creating a new event and check if it appears here');
      return;
    }
    
    logger.i('   📋 Your events:');
    for (var doc in userEventsSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String title = data['title'] ?? 'No title';
      bool isActive = data['isActive'] ?? false;
      String created = data['createdAt'] ?? 'Unknown';
      
      logger.i('      - "$title" (${isActive ? "VISIBLE" : "HIDDEN"}) created at $created');
      
      // Check if event data is valid
      if (!isActive) {
        logger.i('        ⚠️  This event is marked as INACTIVE - users won\'t see it!');
      }
      
      if (data['title'] == null || data['title'].toString().isEmpty) {
        logger.i('        ⚠️  Missing title');
      }
      
      if (data['startDate'] == null) {
        logger.i('        ⚠️  Missing start date');
      }
      
      if (data['categoryId'] == null || data['categoryId'].toString().isEmpty) {
        logger.i('        ⚠️  Missing category ID');
      }
    }
    
  } catch (e) {
    logger.i('   ❌ Error checking user events: $e');
  }
  logger.i('');
}

Future<void> checkSpecificEvent(String eventId) async {
  logger.i('🔍 Checking Specific Event: $eventId');
  try {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();
    
    if (!eventDoc.exists) {
      logger.i('   ❌ Event not found in database');
      return;
    }
    
    Map<String, dynamic> data = eventDoc.data() as Map<String, dynamic>;
    logger.i('   ✅ Event found');
    logger.i('   📋 Event details:');
    logger.i('      Title: ${data['title']}');
    logger.i('      Active: ${data['isActive']}');
    logger.i('      Organizer ID: ${data['organizerId']}');
    logger.i('      Category ID: ${data['categoryId']}');
    logger.i('      Start Date: ${data['startDate']}');
    logger.i('      Created At: ${data['createdAt']}');
    
    // Check if all required fields are present
    List<String> requiredFields = ['id', 'title', 'description', 'startDate', 'endDate', 'categoryId', 'organizerId', 'isActive'];
    List<String> missingFields = [];
    
    for (String field in requiredFields) {
      if (data[field] == null) {
        missingFields.add(field);
      }
    }
    
    if (missingFields.isNotEmpty) {
      logger.i('   ⚠️  Missing required fields: ${missingFields.join(', ')}');
    } else {
      logger.i('   ✅ All required fields present');
    }
    
  } catch (e) {
    logger.i('   ❌ Error checking event: $e');
  }
  logger.i('');
}

// Helper function to test event query that the app uses
Future<void> testEventQuery() async {
  logger.i('🔍 Testing Event Query (same as app uses)...');
  try {
    // This is the same query used in FirestoreService.getEvents()
    Query query = FirebaseFirestore.instance
        .collection('events')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate')
        .limit(20);
    
    QuerySnapshot snapshot = await query.get();
    logger.i('   📊 Events returned by app query: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      logger.i('   ❌ No events returned by the query users see');
      logger.i('   💡 Check if:');
      logger.i('      - Events have isActive = true');
      logger.i('      - Events have valid startDate');
      logger.i('      - Firebase security rules allow reading');
    } else {
      logger.i('   ✅ Events are being returned by user query');
      for (var doc in snapshot.docs.take(3)) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        logger.i('      - "${data['title']}" (${data['startDate']})');
      }
    }
    
  } catch (e) {
    logger.i('   ❌ Error testing query: $e');
    if (e.toString().contains('PERMISSION_DENIED')) {
      logger.i('   🔒 This might be a Firebase security rules issue');
    }
  }
  logger.i('');
}
