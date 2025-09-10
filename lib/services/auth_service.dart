import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
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

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _logger.i('Starting Google Sign-In process');
      
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in process
        _logger.w('Google Sign-In cancelled by user');
        return null;
      }
      
      _logger.i('Google Sign-In account obtained: ${googleUser.email}');
      
      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Missing Google Sign-In tokens');
      }
      
      // Create a new credential for Firebase Auth
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      _logger.i('Authenticating with Firebase using Google credentials');
      
      // Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        _logger.i('Google Sign-In successful for user: ${userCredential.user!.uid}');
        
        // Check if this is a new user or existing user
        final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          _logger.i('New user detected, creating user profile');
          
          // Create user profile in Firestore for new users
          final userModel = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? 'Google User',
            phoneNumber: userCredential.user!.phoneNumber,
            profileImage: userCredential.user!.photoURL,
            favoriteEvents: [],
            attendedEvents: [],
            isAdmin: false, // New Google users are not admin by default
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _firestoreService.createUser(userModel);
          _logger.i('User profile created for new Google user: ${userCredential.user!.uid}');
        } else {
          _logger.i('Existing user signed in with Google');
          
          // Ensure user profile exists (for users who signed up before Google Sign-In was implemented)
          await ensureUserProfileExists();
        }
        
        return userCredential;
      }
      
      _logger.e('Google Sign-In failed: no user in credential');
      return null;
      
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error during Google Sign-In: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Auth errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('An account already exists with a different sign-in method for this email.');
        case 'invalid-credential':
          throw Exception('The credential is invalid or has expired.');
        case 'operation-not-allowed':
          throw Exception('Google Sign-In is not enabled for this project.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        default:
          throw Exception('Google Sign-In failed: ${e.message}');
      }
    } catch (e) {
      _logger.e('Unexpected error during Google Sign-In: $e');
      throw Exception('Google Sign-In failed: $e');
    }
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
      _logger.i('Starting sign out process');
      
      // Sign out from Google if user signed in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        await _googleSignIn.signOut();
        _logger.i('Google Sign-Out completed');
      }
      
      // Sign out from Firebase Auth
      await _auth.signOut();
      _logger.i('Firebase Auth sign out completed');
      
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