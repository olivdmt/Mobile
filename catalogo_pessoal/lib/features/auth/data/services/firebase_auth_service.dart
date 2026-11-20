import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

/// Único ponto da aplicação que conhece o SDK Firebase Authentication.
class FirebaseAuthService {
  FirebaseAuthService(this._auth);

  final FirebaseAuth _auth;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<AuthIdentity?> watchSession() => _auth
      .userChanges()
      .map(_mapUser)
      .transform(
        StreamTransformer<AuthIdentity?, AuthIdentity?>.fromHandlers(
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseAuthException) {
              sink.addError(AuthServiceException(error.code), stackTrace);
            } else {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );

  Future<AuthIdentity> signUp(String email, String password) =>
      _request(() async {
        final credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _requireIdentity(credential.user);
      });

  Future<AuthIdentity> signIn(String email, String password) =>
      _request(() async {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _requireIdentity(credential.user);
      });

  Future<void> signOut() => _request(_auth.signOut);

  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthNoSessionException();
    if (user.emailVerified) return;
    await _request(user.sendEmailVerification);
  }

  Future<AuthIdentity> reloadCurrentUser() async {
    final current = _auth.currentUser;
    if (current == null) throw const AuthNoSessionException();
    await _request(current.reload);
    return _requireIdentity(_auth.currentUser);
  }

  Future<void> requestPasswordReset(String email) =>
      _request(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<T> _request<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(error.code);
    }
  }

  AuthIdentity _requireIdentity(User? user) {
    if (user == null) throw const AuthNoSessionException();
    return AuthIdentity(
      id: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }

  AuthIdentity? _mapUser(User? user) => user == null
      ? null
      : AuthIdentity(
          id: user.uid,
          email: user.email,
          emailVerified: user.emailVerified,
        );
}

class AuthIdentity {
  const AuthIdentity({
    required this.id,
    this.email,
    required this.emailVerified,
  });

  final String id;
  final String? email;
  final bool emailVerified;
}

class AuthServiceException implements Exception {
  const AuthServiceException(this.code);

  final String code;
}

class AuthNoSessionException implements Exception {
  const AuthNoSessionException();
}
