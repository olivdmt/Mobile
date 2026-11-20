import 'package:flutter/foundation.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/domain/auth_failure.dart';

enum AuthActionStatus { idle, loading, success, failure }

class AuthFormViewModel extends ChangeNotifier {
  AuthFormViewModel(this._repository);

  final AuthRepository _repository;
  AuthActionStatus status = AuthActionStatus.idle;
  AuthFailure? failure;

  bool get isLoading => status == AuthActionStatus.loading;

  Future<void> signIn(String email, String password) =>
      _run(() => _repository.signIn(email: email, password: password));

  Future<void> signUp(String email, String password) =>
      _run(() => _repository.signUp(email: email, password: password));

  Future<void> signOut() => _run(_repository.signOut);

  Future<void> sendVerificationEmail() =>
      _run(_repository.sendVerificationEmail);

  Future<void> reloadCurrentUser() => _run(_repository.reloadCurrentUser);

  Future<void> requestPasswordReset(String email) =>
      _run(() => _repository.requestPasswordReset(email));

  void clearFailure() {
    failure = null;
    status = AuthActionStatus.idle;
    notifyListeners();
  }

  Future<void> _run<T>(Future<T> Function() operation) async {
    if (isLoading) return;
    status = AuthActionStatus.loading;
    failure = null;
    notifyListeners();
    try {
      await operation();
      status = AuthActionStatus.success;
    } on AuthFailure catch (error) {
      failure = error;
      status = AuthActionStatus.failure;
    } catch (_) {
      failure = const AuthFailure(AuthFailureKind.unexpected);
      status = AuthActionStatus.failure;
    }
    notifyListeners();
  }
}
