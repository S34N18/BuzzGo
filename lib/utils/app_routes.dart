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
      payment: (context) => const PaymentScreen(),
      paymentHistory: (context) => const PaymentHistoryScreen(),
    };
  }

  // Route generator for dynamic routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
          settings: settings,
        );

      case eventList:
        return MaterialPageRoute(
          builder: (context) => const EventListScreen(),
          settings: settings,
        );

      case eventDetail:
        return MaterialPageRoute(
          builder: (context) => const EventDetailScreen(),
          settings: settings,
        );

      case createEvent:
        return MaterialPageRoute(
          builder: (context) => const CreateEventScreen(),
          settings: settings,
        );

      case myEvents:
        return MaterialPageRoute(
          builder: (context) => const MyEventsScreen(),
          settings: settings,
        );

      case adminDashboard:
        return MaterialPageRoute(
          builder: (context) => const AdminDashboardScreen(),
          settings: settings,
        );

      case manageEvents:
        return MaterialPageRoute(
          builder: (context) => const ManageEventsScreen(),
          settings: settings,
        );

      case analytics:
        return MaterialPageRoute(
          builder: (context) => const AnalyticsScreen(),
          settings: settings,
        );

      case payment:
        return MaterialPageRoute(
          builder: (context) => const PaymentScreen(),
          settings: settings,
        );

      case paymentHistory:
        return MaterialPageRoute(
          builder: (context) => const PaymentHistoryScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (context) => const NotFoundScreen(),
          settings: settings,
        );
    }
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

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.of(context).popUntil(predicate);
  }

  // Custom transitions
  static Route<T> slideTransition<T>(
    Widget page,
    RouteSettings settings, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: child,
        );
      },
    );
  }

  static Route<T> fadeTransition<T>(
    Widget page,
    RouteSettings settings, {
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: curve,
          ),
          child: child,
        );
      },
    );
  }

  static Route<T> scaleTransition<T>(
    Widget page,
    RouteSettings settings, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: child,
        );
      },
    );
  }

  // Route guards
  static bool canNavigateToAdminRoutes(BuildContext context) {
    // Add logic to check if user is admin
    // This would typically check the user's role from a provider
    return true; // Placeholder
  }

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

  // Route middleware
  static Route<dynamic>? authGuard(RouteSettings settings) {
    if (isAuthRequired(settings.name ?? '')) {
      // Check if user is authenticated
      // If not, redirect to login
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: settings,
      );
    }
    return null;
  }

  static Route<dynamic>? adminGuard(RouteSettings settings) {
    if (isAdminRequired(settings.name ?? '')) {
      // Check if user is admin
      // If not, redirect to home or show error
      return MaterialPageRoute(
        builder: (context) => const UnauthorizedScreen(),
        settings: settings,
      );
    }
    return null;
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
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Page Not Found',
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'The page you are looking for does not exist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unauthorized'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'You do not have permission to access this page.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}