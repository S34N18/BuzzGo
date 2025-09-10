// Script to create test categories if none exist
// Run with: dart create_categories.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize logger
  Logger logger = Logger();
  
  logger.i('🏷️ Creating Default Categories for BuzzGo');
  logger.i('==========================================');
  
  try {
    // Check if categories already exist
    QuerySnapshot existingCategories = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    
    if (existingCategories.docs.isNotEmpty) {
      logger.i('✅ Categories already exist: ${existingCategories.docs.length}');
      logger.i('📋 Existing categories:');
      for (var doc in existingCategories.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        logger.i('   - ${data['name']} (${data['isActive'] ? 'Active' : 'Inactive'})');
      }
      return;
    }
    
    logger.i('📝 No categories found. Creating default categories...');
    
    // Default categories for events
    List<Map<String, dynamic>> defaultCategories = [
      {
        'id': 'music',
        'name': 'Music & Concerts',
        'description': 'Live music, concerts, festivals',
        'icon': 'music_note',
        'color': '#FF6B6B',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'business',
        'name': 'Business & Professional',
        'description': 'Conferences, networking, workshops',
        'icon': 'business',
        'color': '#4ECDC4',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'sports',
        'name': 'Sports & Fitness',
        'description': 'Sports events, fitness classes, marathons',
        'icon': 'sports',
        'color': '#45B7D1',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'food',
        'name': 'Food & Drink',
        'description': 'Food festivals, wine tasting, cooking classes',
        'icon': 'restaurant',
        'color': '#FFA726',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'arts',
        'name': 'Arts & Culture',
        'description': 'Art exhibitions, theater, cultural events',
        'icon': 'palette',
        'color': '#AB47BC',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'tech',
        'name': 'Technology',
        'description': 'Tech meetups, hackathons, developer events',
        'icon': 'computer',
        'color': '#66BB6A',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'education',
        'name': 'Education & Learning',
        'description': 'Workshops, seminars, training sessions',
        'icon': 'school',
        'color': '#5C6BC0',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'community',
        'name': 'Community & Social',
        'description': 'Community gatherings, social events, meetups',
        'icon': 'group',
        'color': '#EF5350',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
    
    // Create categories in Firestore
    WriteBatch batch = FirebaseFirestore.instance.batch();
    
    for (var category in defaultCategories) {
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(category['id']);
      batch.set(docRef, category);
    }
    
    await batch.commit();
    
    logger.i('✅ Successfully created ${defaultCategories.length} categories!');
    logger.i('📋 Created categories:');
    for (var category in defaultCategories) {
      logger.i('   - ${category['name']} (ID: ${category['id']})');
    }
    
  } catch (e) {
    logger.e('❌ Error creating categories: $e');
  }
}
