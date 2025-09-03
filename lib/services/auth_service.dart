import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final Logger _logger = Logger();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password (alias for signUpWithEmailAndPassword)
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password, String name) async {
    return signUpWithEmailAndPassword(email, password, name);
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update the user's display name
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
        
        // Create user profile in Firestore using your UserModel
        final userModel = UserModel(
          id: result.user!.uid,
          email: email,
          name: name,
          phoneNumber: result.user!.phoneNumber,
          profileImage: result.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // Add other fields as needed from your UserModel
        );
        
        await _firestoreService.createUser(userModel);
        _logger.i('User created and profile saved: ${result.user!.uid}');
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      _logger.e('Sign up error: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during sign up: $e');
      return null;
    }
  }

  // Sign in with email and password - with better error handling
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _logger.i('Attempting sign in for email: $email');
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _logger.i('Sign in successful for user: ${result.user?.uid}');
      return result;
      
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // Handle the specific type casting error while checking if auth succeeded
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('type cast') ||
          e.toString().contains('List<Object?>')) {
        
        _logger.w('Type casting error occurred, checking if auth succeeded: $e');
        
        // Wait a moment for auth state to update
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Check if user is actually signed in despite the error
        User? currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          _logger.i('Authentication succeeded despite type error for user: ${currentUser.uid}');
          // Return a mock UserCredential since auth actually worked
          return MockUserCredential(currentUser);
        }
      }
      
      _logger.e('Unexpected error during sign in: $e');
      rethrow;
    }
  }

  // Sign in with Google (stub method - not implemented)
  Future<UserCredential?> signInWithGoogle() async {
    throw UnimplementedError('Google Sign-In is not implemented');
  }

  // Reset password (alias for sendPasswordResetEmail)
  Future<void> resetPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _logger.e('Password reset error: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during password reset: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user profile from Firestore first
        await _firestoreService.deleteUser(user.uid);
        
        // Then delete the auth user
        await user.delete();
        
        _logger.i('User account and profile deleted: ${user.uid}');
      }
    } on FirebaseAuthException catch (e) {
      _logger.e('Delete account error: ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Unexpected error during account deletion: $e');
      rethrow;
    }
  }

  // Update user profile (alias for updateProfile)
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    return updateProfile(displayName: displayName, photoURL: photoURL);
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update Firebase Auth profile
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
        
        // Update Firestore profile using your UserModel
        UserModel? existingUser = await _firestoreService.getUser(user.uid);
        if (existingUser != null) {
          UserModel updatedUser = existingUser.copyWith(
            name: displayName ?? existingUser.name,
            profileImage: photoURL ?? existingUser.profileImage,
            updatedAt: DateTime.now(),
          );
          
          await _firestoreService.updateUser(updatedUser);
        }
        
        _logger.i('Profile updated for user: ${user.uid}');
      }
    } catch (e) {
      _logger.e('Profile update error: $e');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      _logger.e('Email verification error: $e');
      rethrow;
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await _firestoreService.getUser(user.uid);
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user profile: $e');
      return null;
    }
  }

  // Check if user exists in Firestore
  Future<bool> doesUserProfileExist() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        UserModel? profile = await _firestoreService.getUser(user.uid);
        return profile != null;
      }
      return false;
    } catch (e) {
      _logger.e('Error checking user profile existence: $e');
      return false;
    }
  }

  // Create user profile if it doesn't exist (useful for existing users)
  Future<void> ensureUserProfileExists() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        bool exists = await doesUserProfileExist();
        if (!exists) {
          final userModel = UserModel(
            id: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            phoneNumber: user.phoneNumber,
            profileImage: user.photoURL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _firestoreService.createUser(userModel);
          _logger.i('User profile created for existing auth user: ${user.uid}');
        }
      }
    } catch (e) {
      _logger.e('Error ensuring user profile exists: $e');
    }
  }
}

// Mock UserCredential for type casting error workaround
class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential(this.user);

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
}