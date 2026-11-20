import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:catalogo_pessoal/features/auth/data/repositories/auth_repository.dart';
import 'package:catalogo_pessoal/features/auth/domain/app_user.dart';

enum SessionStatus { checking, signedOut, signedIn }

class AuthSessionViewModel extends ChangeNotifier {
  AuthSessionViewModel(this._repository);

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;
  SessionStatus status = SessionStatus.checking;
  AppUser? user;
  Object? streamError;

  void start() {
    if (_subscription != null) return;
    _subscription = _repository.watchSession().listen(
      (value) {
        user = value;
        status = value == null
            ? SessionStatus.signedOut
            : SessionStatus.signedIn;
        streamError = null;
        notifyListeners();
      },
      onError: (Object error) {
        streamError = error;
        status = SessionStatus.signedOut;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
