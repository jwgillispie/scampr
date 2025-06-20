import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ApiService _apiService;
  AppUser? _currentUser;
  final StreamController<AppUser?> _authStateController = StreamController<AppUser?>.broadcast();

  AuthService({required ApiService apiService}) : _apiService = apiService {
    // Listen to Firebase auth state changes
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Get current user
  AppUser? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null && _currentUser != null;

  // Auth state changes stream
  Stream<AppUser?> get authStateChanges => _authStateController.stream;

  void _notifyAuthStateChange() {
    _authStateController.add(_currentUser);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      // User is signed in, create/sync with MongoDB backend
      try {
        await _syncUserWithBackend(firebaseUser);
      } catch (e) {
        print('Error syncing user with backend: $e');
      }
    } else {
      // User is signed out
      _currentUser = null;
      _notifyAuthStateChange();
    }
  }

  Future<void> _syncUserWithBackend(User firebaseUser) async {
    try {
      // Sync Firebase user with MongoDB backend
      await _apiService.syncFirebaseUser(
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        firebaseUid: firebaseUser.uid,
      );

      // Create AppUser from Firebase User data
      _currentUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        profileImageUrl: firebaseUser.photoURL,
        climbedTrees: [],
        addedTrees: [],
        joinedDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
        totalClimbs: 0,
      );
      
      _notifyAuthStateChange();
    } catch (e) {
      // Still create local user even if backend sync fails
      _currentUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        profileImageUrl: firebaseUser.photoURL,
        climbedTrees: [],
        addedTrees: [],
        joinedDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
        totalClimbs: 0,
      );
      _notifyAuthStateChange();
    }
  }

  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Wait for user to be synced with backend
        await _syncUserWithBackend(result.user!);
        return _currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<AppUser?> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update display name in Firebase
        await result.user!.updateDisplayName(displayName);
        
        // Wait for user to be synced with backend
        await _syncUserWithBackend(result.user!);
        return _currentUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Firebase auth state change will handle clearing _currentUser
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getFirebaseAuthErrorMessage(e));
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        // Update local user object
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(displayName: displayName);
          _notifyAuthStateChange();
        }
      }
    } catch (e) {
      throw Exception('Display name update failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      // Re-authenticate user before deletion (required for security)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      
      await user.reauthenticateWithCredential(credential);

      // Delete user data from MongoDB backend
      try {
        await _apiService.deleteUserAccount(user.uid);
      } catch (e) {
        // Warning: Could not delete user data from backend: $e
        // Continue with Firebase account deletion even if backend deletion fails
      }

      // Delete the Firebase Auth account
      await user.delete();
      
      // Clear local user state
      _currentUser = null;
      _notifyAuthStateChange();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception('Incorrect password. Please try again.');
        case 'requires-recent-login':
          throw Exception('Please sign out and sign in again before deleting your account.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception('Account deletion failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  void dispose() {
    _authStateController.close();
  }
}