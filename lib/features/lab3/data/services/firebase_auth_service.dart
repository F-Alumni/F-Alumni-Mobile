import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseGoogleSignInResult {
  const FirebaseGoogleSignInResult({
    required this.firebaseUser,
    required this.googleIdToken,
  });

  final User firebaseUser;
  final String googleIdToken;
}

/// Firebase identity boundary for Lab 3.
///
/// API session exchange remains a separate responsibility until the app's
/// Firebase-to-backend authentication contract is confirmed.
class FirebaseAuthService {
  FirebaseAuthService(this._auth, {GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<bool> get signedInChanges =>
      _auth.authStateChanges().map((user) => user != null);

  User? get currentUser => _auth.currentUser;

  Future<FirebaseGoogleSignInResult> signInWithGoogle({
    String? clientId,
    String? serverClientId,
  }) async {
    _googleInitialization ??= _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    await _googleInitialization;

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In did not return an ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw StateError('Firebase Authentication returned no user.');
    }
    return FirebaseGoogleSignInResult(
      firebaseUser: user,
      googleIdToken: idToken,
    );
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } finally {
      if (_googleInitialization != null) {
        try {
          await _googleSignIn.signOut();
        } on Object {
          // Firebase sign-out remains authoritative if provider cleanup fails.
        }
      }
    }
  }
}
