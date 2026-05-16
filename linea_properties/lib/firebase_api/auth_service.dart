import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthFailure implements Exception {
  final String message;
  final String? code;

  const AuthFailure(this.message, {this.code});

  @override
  String toString() => code == null ? message : '[$code] $message';
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        if (fullName != null && fullName.trim().isNotEmpty) {
          await user.updateDisplayName(fullName.trim());
        }
        await user.sendEmailVerification();
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    }
  }

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    } catch (e) {
      if (e is AuthFailure) rethrow;
      throw const AuthFailure('Google sign-in failed. Please try again.');
    }
  }

  /// Apple Sign-In via `sign_in_with_apple`.
  ///
  /// Note: on Android/Web you must provide [webAuthenticationOptions].
  Future<UserCredential> signInWithApple({
    WebAuthenticationOptions? webAuthenticationOptions,
  }) async {
    try {
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: webAuthenticationOptions,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
        accessToken: appleCredential.authorizationCode,
        signInMethod: 'apple.com',
      );

      return await _auth.signInWithCredential(oauthCredential);
    } on ArgumentError {
      throw const AuthFailure(
        'Apple sign-in on Android/Web requires webAuthenticationOptions (clientId & redirectUri).',
      );
    } on AssertionError {
      throw const AuthFailure(
        'Apple sign-in on Android/Web requires webAuthenticationOptions (clientId & redirectUri).',
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    } on SignInWithAppleNotSupportedException {
      throw const AuthFailure('Apple sign-in is not supported on this device.');
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure('Apple sign-in cancelled.');
      }
      throw AuthFailure(
        e.message,
        code: e.code.name,
      );
    } catch (_) {
      throw const AuthFailure('Apple sign-in failed. Please try again.');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  Future<String?> getJwt({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken(forceRefresh);
  }

  Future<IdTokenResult?> getIdTokenResult({bool forceRefresh = false}) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdTokenResult(forceRefresh);
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore: still sign out from Firebase below.
    }
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_messageForFirebaseAuth(e), code: e.code);
    }
  }

  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  String _messageForFirebaseAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'User account is disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
