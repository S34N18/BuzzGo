import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class AdminHelper {
  static final Logger _logger = Logger();
  static final FirestoreService _firestoreService = FirestoreService();

  /// Check if current user has admin privileges
  static bool isCurrentUserAdmin(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAdmin;
  }

  /// Navigate only if user is admin, otherwise show access denied
  static void navigateIfAdmin(BuildContext context, String route) {
    if (isCurrentUserAdmin(context)) {
      Navigator.pushNamed(context, route);
    } else {
      _showAccessDenied(context);
    }
  }

  /// Show access denied dialog
  static void _showAccessDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You need administrator privileges to access this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Widget wrapper for admin-only content
  static Widget adminOnly({
    required Widget child,
    Widget? fallback,
    required BuildContext context,
  }) {
    if (isCurrentUserAdmin(context)) {
      return child;
    } else {
      return fallback ?? const SizedBox.shrink();
    }
  }

  /// Debug function to log current admin status
  static void debugAdminStatus(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _logger.d('🔍 Admin Debug:');
    _logger.d('  User ID: ${authProvider.user?.uid}');
    _logger.d('  Email: ${authProvider.user?.email}');
    _logger.d('  Is Admin: ${authProvider.isAdmin}');
    _logger.d('  User Model: ${authProvider.userModel?.toJson()}');
  }

  /// Promote user to admin (for testing/development only)
  static Future<bool> promoteToAdmin(String userId) async {
    try {
      // Get current user data
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        // Update user with admin privileges
        final updatedUser = user.copyWith(
          isAdmin: true,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        _logger.i('✅ User $userId promoted to admin');
        return true;
      }
      _logger.w('❌ User $userId not found');
      return false;
    } catch (e) {
      _logger.e('❌ Error promoting user to admin: $e');
      return false;
    }
  }

  /// Remove admin privileges (for testing/development only)
  static Future<bool> removeAdminPrivileges(String userId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        final updatedUser = user.copyWith(
          isAdmin: false,
          updatedAt: DateTime.now(),
        );
        
        await _firestoreService.updateUser(updatedUser);
        _logger.i('✅ Admin privileges removed from user $userId');
        return true;
      }
      _logger.w('❌ User $userId not found');
      return false;
    } catch (e) {
      _logger.e('❌ Error removing admin privileges: $e');
      return false;
    }
  }

  /// Get all admin users
  static Future<List<String>> getAllAdmins() async {
    try {
      final allUsers = await _firestoreService.getAllUsers();
      return allUsers
          .where((user) => user.isAdmin)
          .map((user) => user.email)
          .toList();
    } catch (e) {
      _logger.e('❌ Error getting admin users: $e');
      return [];
    }
  }
}

/// Custom route guard for admin routes
class AdminRouteGuard extends StatelessWidget {
  final Widget child;
  final String routeName;

  const AdminRouteGuard({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          // Redirect to login if not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (!authProvider.isAdmin) {
          // Show access denied for non-admin users
          return Scaffold(
            appBar: AppBar(
              title: const Text('Access Denied'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Administrator Access Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You need administrator privileges to access this page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        
        return child;
      },
    );
  }
}
