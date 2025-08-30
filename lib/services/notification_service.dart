import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize notifications: $e');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'BuzzGo',
      body: message.notification?.body ?? 'New notification',
      payload: message.data.toString(),
    );
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  // Handle notification tap from Firebase
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification opened app: ${message.messageId}');
    // Handle navigation based on message data
  }

  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'buzzgo_channel',
      'BuzzGo Notifications',
      channelDescription: 'Notifications for BuzzGo events',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule event reminder
  Future<void> scheduleEventReminder(EventModel event) async {
    final reminderTime = event.startDate.subtract(const Duration(hours: 2));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _localNotifications.zonedSchedule(
        event.id.hashCode,
        'Event Reminder',
        '${event.title} starts in 2 hours!',
        _convertToTZDateTime(reminderTime),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_reminders',
            'Event Reminders',
            channelDescription: 'Reminders for upcoming events',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'event_reminder:${event.id}',
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  // Cancel event reminder
  Future<void> cancelEventReminder(String eventId) async {
    await _localNotifications.cancel(eventId.hashCode);
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Check notification permissions
  Future<bool> hasNotificationPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Request notification permissions
  Future<bool> requestNotificationPermission() async {
    final settings = await _firebaseMessaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Helper method to convert DateTime to TZDateTime
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // This is a simplified implementation
    // In a real app, you'd use the timezone package
    return dateTime;
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}