// Debug script to check admin privileges
// Run with: dart debug_admin.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

void main() async {
  Logger logger = Logger();

  // Initialize Firebase (you'll need your firebase_options.dart)
  await Firebase.initializeApp();
  
  // Get current user
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser == null) {
    logger.d('❌ No user is currently logged in');
    logger.d('Please log in first and run this script again');
    return;
  }
  
  logger.d('🔍 Debugging admin status for user: ${currentUser.uid}');
  logger.d('📧 Email: ${currentUser.email}');
  
  try {
    // Query Firestore for user document
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      logger.d('✅ User document found in Firestore');
      logger.d('📋 User data:');
      logger.d('   Name: ${userData['name']}');
      logger.d('   Email: ${userData['email']}');
      logger.d('   Admin Status: ${userData['isAdmin'] ?? false}');
      logger.d('   Created: ${userData['createdAt']}');
      logger.d('   Updated: ${userData['updatedAt']}');
      
      // Check admin status
      bool isAdmin = userData['isAdmin'] ?? false;
      if (isAdmin) {
        logger.d('🎉 USER HAS ADMIN PRIVILEGES');
      } else {
        logger.d('⚠️  USER DOES NOT HAVE ADMIN PRIVILEGES');
        logger.d('');
        logger.d('To grant admin access, update Firestore:');
        logger.d('1. Go to Firebase Console > Firestore');
        logger.d('2. Find users collection > ${currentUser.uid}');
        logger.d('3. Set isAdmin field to true');
        logger.d('');
        logger.d('Or run: flutter run and use the admin promotion feature');
      }
    } else {
      logger.d('❌ User document NOT found in Firestore');
      logger.d('This means the user profile was not created properly');
      logger.d('');
      logger.d('To fix this:');
      logger.d('1. Log into the app normally');
      logger.d('2. The AuthProvider should create the user document automatically');
      logger.d('3. Or manually create user document with isAdmin: true');
    }
    
  } catch (e) {
    logger.d('❌ Error checking admin status: $e');
  }
}
