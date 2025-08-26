import 'package:firebase_auth/firebase_auth.dart';
// REMOVE this line: import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return null;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Password reset error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during password reset: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // REMOVE this line: await GoogleSignIn().signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      print('Delete account error: ${e.message}');
      throw e;
    } catch (e) {
      print('Unexpected error during account deletion: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
      }
    } catch (e) {
      print('Profile update error: $e');
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
      print('Email verification error: $e');
      rethrow;
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }
}