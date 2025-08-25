import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
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
      _userModel = await _firestoreService.getUser(userId);
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.signInWithEmailAndPassword(email, password);
      
      if (result != null) {
        await _loadUserModel(result.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.registerWithEmailAndPassword(email, password, name);
      
      if (result != null) {
        await _loadUserModel(result.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      UserCredential? result = await _authService.signInWithGoogle();
      
      if (result != null) {
        await _loadUserModel(result.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.signOut();
      _user = null;
      _userModel = null;
    } catch (e) {
      _setError('Sign out failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
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
        return true;
      }
      return false;
    } catch (e) {
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
}