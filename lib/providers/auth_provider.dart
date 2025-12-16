import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configure GoogleSignIn properly
  late final GoogleSignIn _googleSignIn;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    // Initialize GoogleSignIn with proper scopes
    _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
    _initialize();
  }

  /// Initialize authentication state
  Future<void> _initialize() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Try to restore existing Firebase auth user
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser.uid);
      }

      // Listen to auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user == null) {
          _currentUser = null;
          notifyListeners();
        }
      });

      _initialized = true;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Initialization failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web platform
        final provider = GoogleAuthProvider();
        provider.addScope('email');
        provider.addScope('profile');

        final UserCredential userCredential = await _auth.signInWithPopup(
          provider,
        );

        if (userCredential.user == null) {
          _errorMessage = 'Sign in failed: No user data';
          return false;
        }

        await _createOrUpdateUser(userCredential.user!);
        await _loadUserData(userCredential.user!.uid);
        return true;
      }

      // Sign out first to ensure clean state
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _errorMessage = 'Sign in cancelled';
        return false;
      }

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _errorMessage = 'Failed to obtain authentication tokens';
        return false;
      }

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        _errorMessage = 'Firebase sign in failed: No user data';
        return false;
      }

      await _createOrUpdateUser(userCredential.user!);
      await _loadUserData(userCredential.user!.uid);

      return true;
    } catch (e) {
      // Handle specific error types
      if (e.toString().contains('network_error')) {
        _errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('sign_in_canceled')) {
        _errorMessage = 'Sign in was cancelled';
      } else if (e.toString().contains('sign_in_failed')) {
        _errorMessage = 'Sign in failed. Please try again.';
      } else if (e is FirebaseAuthException) {
        _errorMessage = _getFirebaseAuthErrorMessage(e);
      } else {
        _errorMessage = 'Sign in failed: ${e.toString()}';
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get user-friendly Firebase Auth error messages
  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled. Please contact support';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication error: ${e.message ?? e.code}';
    }
  }

  /// Create or update user in Firestore
  Future<void> _createOrUpdateUser(User firebaseUser) async {
    try {
      final userRef = _firestore.collection('users').doc(firebaseUser.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Create new user
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Student',
          photoUrl: firebaseUser.photoURL ?? '',
          role: 'student',
          createdAt: DateTime.now(),
        );

        await userRef.set(newUser.toMap());
      } else {
        // Update existing user
        await userRef.update({
          'lastLogin': DateTime.now().toIso8601String(),
          'email': firebaseUser.email ?? userDoc.data()?['email'] ?? '',
          'displayName':
              firebaseUser.displayName ??
              userDoc.data()?['displayName'] ??
              'Student',
          'photoUrl':
              firebaseUser.photoURL ?? userDoc.data()?['photoUrl'] ?? '',
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to save user data: ${e.toString()}';
      rethrow; // Re-throw to handle in calling function
    }
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromMap(userDoc.data()!);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: ${e.toString()}';
    }
    notifyListeners();
  }

  /// Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Sign out from Google Sign-In
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
          await _googleSignIn.disconnect();
        } catch (e) {
          print('AuthProvider: Google Sign Out error (non-critical): $e');
        }
      }

      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to sign out: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Admin: update user role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({'role': role});
      if (_currentUser?.uid == uid) {
        await _loadUserData(uid);
      }
    } catch (e) {
      _errorMessage = 'Failed to update user role: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
