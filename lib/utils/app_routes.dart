import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/events/my_events_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_events_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/admin_events_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/payment/payment_screen.dart';
import '../screens/payment/payment_history_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String eventList = '/events';
  static const String eventDetail = '/event-detail';
  static const String createEvent = '/create-event';
  static const String myEvents = '/my-events';
  static const String adminDashboard = '/admin-dashboard';
  static const String manageEvents = '/manage-events';
  static const String analytics = '/analytics';
  static const String adminEvents = '/admin-events';
  static const String adminUsers = '/admin-users';
  static const String payment = '/payment';
  static const String paymentHistory = '/payment-history';

  // Route map
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      profile: (context) => const ProfileScreen(),
      eventList: (context) => const EventListScreen(),
      eventDetail: (context) => const EventDetailScreen(),
      createEvent: (context) => const CreateEventScreen(),
      myEvents: (context) => const MyEventsScreen(),
      adminDashboard: (context) => const AdminDashboardScreen(),
      manageEvents: (context) => const ManageEventsScreen(),
      analytics: (context) => const AnalyticsScreen(),
      adminEvents: (context) => const AdminEventsScreen(),
      adminUsers: (context) => const AdminUsersScreen(),
      payment: (context) => const PaymentScreen(),
      paymentHistory: (context) => const PaymentHistoryScreen(),
    };
  }

  // Navigation helpers
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  // Route guards
  static bool isAuthRequired(String routeName) {
    const authRequiredRoutes = [
      profile,
      createEvent,
      myEvents,
      adminDashboard,
      manageEvents,
      analytics,
      payment,
      paymentHistory,
    ];
    return authRequiredRoutes.contains(routeName);
  }

  static bool isAdminRequired(String routeName) {
    const adminRequiredRoutes = [
      adminDashboard,
      manageEvents,
      analytics,
    ];
    return adminRequiredRoutes.contains(routeName);
  }
}

// Error screens
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Page Not Found', style: TextStyle(fontSize: 24, color: Colors.grey)),
            SizedBox(height: 16),
            Text('The page you are looking for does not exist.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}