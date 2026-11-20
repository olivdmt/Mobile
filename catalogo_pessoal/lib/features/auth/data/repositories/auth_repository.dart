import 'dart:async';

import 'package:catalogo_pessoal/features/auth/data/services/firebase_auth_service.dart';
import 'package:catalogo_pessoal/features/auth/domain/app_user.dart';
import 'package:catalogo_pessoal/features/auth/domain/auth_failure.dart';

abstract interface class AuthRepository {
  String? get currentUserId;
  Stream<AppUser?> watchSession();
  Future<AppUser> signUp({required String email, required String password});
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
  Future<void> sendVerificationEmail();
  Future<AppUser> reloadCurrentUser();
  Future<void> requestPasswordReset(String email);
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._service);

  final FirebaseAuthService _service;

  @override
  String? get currentUserId => _service.currentUserId;

  @override
  Stream<AppUser?> watchSession() =>
      _service.watchSession().map(_mapIdentityNullable);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return _mapIdentity(await _service.signUp(email.trim(), password));
    } on AuthServiceException catch (error) {
      throw _mapFailure(error.code);
    } on AuthNoSessionException {
      throw const AuthFailure(AuthFailureKind.noSession);
    }
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return _mapIdentity(await _service.signIn(email.trim(), password));
    } on AuthServiceException catch (error) {
      throw _mapFailure(error.code);
    } on AuthNoSessionException {
      throw const AuthFailure(AuthFailureKind.noSession);
    }
  }

  @override
  Future<void> signOut() => _run(_service.signOut);

  @override
  Future<void> sendVerificationEmail() => _run(_service.sendVerificationEmail);

  @override
  Future<AppUser> reloadCurrentUser() async {
    try {
      return _mapIdentity(await _service.reloadCurrentUser());
    } on AuthServiceException catch (error) {
      throw _mapFailure(error.code);
    } on AuthNoSessionException {
      throw const AuthFailure(AuthFailureKind.noSession);
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _service.requestPasswordReset(email.trim());
    } on AuthServiceException catch (error) {
      // Responder da mesma forma para e-mails cadastrados e desconhecidos.
      if (error.code == 'user-not-found') return;
      throw _mapFailure(error.code);
    }
  }

  Future<void> _run(Future<void> Function() operation) async {
    try {
      await operation();
    } on AuthServiceException catch (error) {
      throw _mapFailure(error.code);
    } on AuthNoSessionException {
      throw const AuthFailure(AuthFailureKind.noSession);
    }
  }

  AppUser _mapIdentity(AuthIdentity user) => AppUser(
    id: user.id,
    email: user.email,
    emailVerified: user.emailVerified,
  );

  AppUser? _mapIdentityNullable(AuthIdentity? user) =>
      user == null ? null : _mapIdentity(user);

  AuthFailure _mapFailure(String code) {
    final kind = switch (code) {
      'invalid-email' => AuthFailureKind.invalidInput,
      'weak-password' ||
      'password-does-not-meet-requirements' => AuthFailureKind.weakPassword,
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => AuthFailureKind.invalidCredential,
      'too-many-requests' => AuthFailureKind.rateLimited,
      'network-request-failed' => AuthFailureKind.network,
      'email-already-in-use' => AuthFailureKind.emailInUse,
      _ => AuthFailureKind.unexpected,
    };
    return AuthFailure(kind);
  }
}

/// Repositório controlável para testes de ViewModels sem Firebase ou rede.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.initialUser}) : _user = initialUser;

  final AppUser? initialUser;
  final _session = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  @override
  String? get currentUserId => _user?.id;

  @override
  Stream<AppUser?> watchSession() async* {
    yield _user;
    yield* _session.stream;
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'fake-uid',
      email: email.trim(),
      emailVerified: false,
    );
    _user = user;
    _session.add(user);
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = AppUser(
      id: 'fake-uid',
      email: email.trim(),
      emailVerified: false,
    );
    _user = user;
    _session.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _session.add(null);
  }

  @override
  Future<void> sendVerificationEmail() async {}

  @override
  Future<AppUser> reloadCurrentUser() async =>
      _user ?? (throw const AuthFailure(AuthFailureKind.noSession));

  @override
  Future<void> requestPasswordReset(String email) async {}

  Future<void> dispose() => _session.close();
}
