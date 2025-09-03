import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final Logger _logger = Logger();
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  // Initialize authentication state
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _logger.i(' Auth state changed: ${user?.uid}');
      _user = user;
      if (user != null) {
        await _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String userId) async {
    try {
      _logger.i(' Loading user model for: $userId');
      _userModel = await _firestoreService.getUser(userId);
      
      if (_userModel == null) {
        _logger.w(' User model not found, creating one...');
        await _createUserModelFromAuth();
      } else {
        _logger.i(' User model loaded: ${_userModel?.name}');
      }
    } catch (e) {
      _logger.e(' Failed to load user model: $e');
      _errorMessage = 'Failed to load user data: ${e.toString()}';
      // Try to create user model if it doesn't exist
      await _createUserModelFromAuth();
    }
  }

  // Create user model from current Firebase Auth user
  Future<void> _createUserModelFromAuth() async {
    try {
      if (_user != null) {
        _logger.i(' Creating user model from auth user: ${_user!.uid}');
        
        UserModel newUser = UserModel(
          id: _user!.uid,
          email: _user!.email ?? '',
          name: _user!.displayName ?? 'User',
          phoneNumber: _user!.phoneNumber ?? '',
          profileImage: _user!.photoURL ?? '',
          favoriteEvents: [],
          isAdmin: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestoreService.createUser(newUser);
        _userModel = newUser;
        _logger.i(' User model created successfully');
      }
    } catch (e) {
      _logger.e(' Failed to create user model: $e');
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _logger.i(' Attempting login for: $email');
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.signInWithEmailAndPassword(email, password);
      
      if (result != null) {
        _logger.i(' Login successful: ${result.user!.uid}');
        // The auth state listener will handle loading the user model
        return true;
      }
      
      _logger.e(' Login failed: No result');
      return false;
    } on FirebaseAuthException catch (e) {
      _logger.e(' Firebase Auth error: ${e.code} - ${e.message}');
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _logger.e(' Login error: $e');
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      _logger.i(' Attempting registration for: $email');
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
      );

      if (result != null) {
        _logger.i(' Registration successful: ${result.user!.uid}');
        
        // The AuthService already creates the user model during registration,
        // but let's ensure it's loaded in our provider
        await _loadUserModel(result.user!.uid);
        return true;
      }
      
      _logger.e(' Registration failed: No result');
      return false;
    } on FirebaseAuthException catch (e) {
      _logger.e(' Firebase Auth error during registration: ${e.code} - ${e.message}');
      _setError(_getFirebaseErrorMessage(e.code));
      return false;
    } catch (e) {
      _logger.e(' Registration error: $e');
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _logger.i(' Attempting Google sign in');
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.signInWithGoogle();
      
      if (result != null) {
        _logger.i(' Google sign in successful: ${result.user!.uid}');
        // The auth state listener will handle loading the user model
        return true;
      }
      return false;
    } catch (e) {
      _logger.e(' Google sign in error: $e');
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.i(' Signing out');
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _user = null;
      _userModel = null;
      _logger.i(' Sign out successful');
    } catch (e) {
      _logger.e(' Sign out error: $e');
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _logger.i(' Sending password reset for: $email');
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      _logger.i(' Password reset email sent');
      return true;
    } catch (e) {
      _logger.e(' Password reset error: $e');
      _setError('Password reset failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) async {
    try {
      _logger.i(' Updating user profile');
      _setLoading(true);
      _clearError();

      if (_userModel != null) {
        UserModel updatedUser = _userModel!.copyWith(
          name: name ?? _userModel!.name,
          phoneNumber: phoneNumber ?? _userModel!.phoneNumber,
          profileImage: profileImage ?? _userModel!.profileImage,
          updatedAt: DateTime.now(),
        );

        await _firestoreService.updateUser(updatedUser);
        
        // Update Firebase Auth profile
        await _authService.updateUserProfile(
          displayName: updatedUser.name,
          photoURL: updatedUser.profileImage,
        );

        _userModel = updatedUser;
        _logger.i(' Profile updated successfully');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _logger.e(' Profile update error: $e');
      _setError('Profile update failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add event to favorites
  Future<bool> addToFavorites(String eventId) async {
    try {
      if (_userModel != null) {
        List<String> updatedFavorites = List.from(_userModel!.favoriteEvents);
        if (!updatedFavorites.contains(eventId)) {
          updatedFavorites.add(eventId);
          
          UserModel updatedUser = _userModel!.copyWith(
            favoriteEvents: updatedFavorites,
            updatedAt: DateTime.now(),
          );

          await _firestoreService.updateUser(updatedUser);
          _userModel = updatedUser;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError('Failed to add to favorites: ${e.toString()}');
      return false;
    }
  }

  // Remove event from favorites
  Future<bool> removeFromFavorites(String eventId) async {
    try {
      if (_userModel != null) {
        List<String> updatedFavorites = List.from(_userModel!.favoriteEvents);
        if (updatedFavorites.contains(eventId)) {
          updatedFavorites.remove(eventId);
          
          UserModel updatedUser = _userModel!.copyWith(
            favoriteEvents: updatedFavorites,
            updatedAt: DateTime.now(),
          );

          await _firestoreService.updateUser(updatedUser);
          _userModel = updatedUser;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _setError('Failed to remove from favorites: ${e.toString()}');
      return false;
    }
  }

  // Check if event is in favorites
  bool isEventFavorite(String eventId) {
    return _userModel?.favoriteEvents.contains(eventId) ?? false;
  }

  // Delete account
  Future<bool> deleteAccount() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.deleteAccount();
      _user = null;
      _userModel = null;
      return true;
    } catch (e) {
      _setError('Account deletion failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user-friendly Firebase error messages
  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
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

  // Handle login method for your login screen
  Future<void> handleLogin(String email, String password, BuildContext context) async {
    _logger.i(' Form validated, attempting login...');
    
    final success = await signInWithEmailAndPassword(
      email.trim(),
      password,
    );

    if (success && context.mounted) {
      _logger.i(' Login successful, navigating to home');
      Navigator.of(context).pushReplacementNamed('/home'); // Replace with your home route
    } else if (context.mounted) {
      _logger.e(' Login failed: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Login failed. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}